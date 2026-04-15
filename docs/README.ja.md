# Team-Driven Development

[English](../README.md)

専門的な役割を持つサブエージェントチームで実装プランを実行する Claude Code プラグインです。

## 概要

単一のエージェントがすべてを行う代わりに、サブエージェントに専門的な役割を割り当てます。

```
                 ┌──────────────────────┐
                 │    Lead (あなた)      │
                 │  指揮のみ、コードは   │
                 │  書かない             │
                 └──────┬───────────────┘
                        │
           ┌────────────┼────────────┐
           ▼            ▼            ▼
     ┌──────────┐ ┌──────────┐ ┌──────────┐
     │ Architect │ │ Worker   │ │ Reviewer │
     │ 設計判断  │ │ Worktree │ │ Sprint   │
     │ (必要時   │ │ 隔離で   │ │ Contract │
     │  のみ)    │ │ 実装     │ │ で検証   │
     └──────────┘ └──────────┘ └──────────┘
```

- **Lead** — プラン解析、チーム編成、タスク割当、統合。実装コードは書かない。
- **Worker** — 隔離された git worktree で単一タスクを実装。TDD とセルフレビューを実行。
- **Reviewer** — Sprint Contract に基づいて完了した作業を検証。`static`、`runtime`、`browser` の3プロファイル。
- **Architect** — 設計判断が必要なタスクのみ召集。Worker 向けの Design Brief を出力。

## 主な機能

- **適応的プロセス選択** — シンプルなプランには Lite Mode を提案、複雑なプランにはフルチームプロセスを使用
- **動的チーム編成** — タスクの複雑度と種類に応じてロールを割り当て
- **Sprint Contract** — 作業開始前に成功条件・非目標・レビュープロファイルを定義
- **Effort Scoring** — タスク複雑度に基づくモデル自動選択（cheap/standard/capable）
- **Worktree 隔離** — Worker は隔離された worktree で作業。承認後にのみ main に反映
- **動的依存解析** — プラン内容（ファイルパス、import、論理的依存）から実行順序を決定
- **並列実行** — 独立したタスクは複数の Worker で同時実行
- **3段階レビュー** — `static`（Lead が diff 確認）、`runtime`（エージェントがテスト実行）、`browser`（エージェント + UI 検証）

## 動作フロー

### Phase A-0: トリアージ
1. プランを読み取り Quick Score を算出（タスク数、ファイル数、ドメイン分散、設計キーワード）
2. Quick Score ≤ 1 → ユーザーに **Lite Mode** を提案
3. ユーザーが承諾 → Lead が直接実装し、最後に Reviewer が一括レビュー
4. ユーザーが拒否 or Quick Score > 1 → Full Mode（Phase A）へ

### Phase A: 事前分析（Full Mode）
1. プランからすべてのタスクを読み取り・抽出
2. 依存関係を動的に解析
3. タスクごとの Effort Score を算出
4. タスクごとの reviewer profile を選択
5. Sprint Contract を生成
6. チーム構成を決定

### Phase B: 実行（タスクごと）
1. Architect を派遣して Design Brief を取得（必要な場合のみ）
2. Worker を隔離 worktree に派遣
3. Sprint Contract に基づいてレビュー
4. REQUEST_CHANGES の場合は修正ループ（最大3回）
5. APPROVE で main に cherry-pick

### Phase C: 完了処理
1. 全結果を収集
2. 完了レポートを生成
3. 全タスクの完了を検証

## インストール

### Claude Code 内から（推奨）

Claude Code セッション内で `/plugin` スラッシュコマンドを使用します：

```
/plugin marketplace add https://github.com/rat-siem/team-driven-development
/plugin install team-driven-development@team-driven-dev
```

### ターミナルから

```bash
# 1. マーケットプレイス登録
claude plugin marketplace add https://github.com/rat-siem/team-driven-development

# 2. インストール
claude plugin install team-driven-development@team-driven-dev
```

### ローカルパスから（開発用）

```bash
claude plugin add /path/to/team-driven-development
```

## アップデート

最新バージョンに更新するには：

```
/plugin update team-driven-development
```

またはターミナルから：

```bash
claude plugin update team-driven-development
```

## 使い方

[Superpowers](https://github.com/obra/superpowers) と組み合わせて使うのが最適ですが、単体でも使用できます。

### Superpowers と併用（推奨）

```
brainstorming → writing-plans → team-driven-development
```

`writing-plans` スキルがプランを出力します。実行方法の選択時に、役割分担が効果的な複雑なプランで Team-Driven Development を選択してください。

### 単体で使用

Superpowers のタスク形式でプランを記述します：

````markdown
### Task 1: [名前]

**Files:**
- Create: `src/models/user.py`
- Test: `tests/test_user.py`

- [ ] **Step 1: 失敗するテストを書く**
```python
def test_user_creation():
    user = User("Alice", "alice@example.com")
    assert user.name == "Alice"
```

- [ ] **Step 2: 実装**
...
````

スキルを呼び出してプランファイルを指定します。

## Sprint Contract の例

```markdown
## Sprint Contract: Task 2 - ユーザー API エンドポイント

### 成功条件
- [ ] GET /api/users が 200 と JSON 配列を返す
- [ ] POST /api/users がユーザーを作成し 201 を返す
- [ ] テスト合格: `pytest tests/test_api.py -v`

### 非目標
- 認証は実装しない（Task 4 の範囲）
- ページネーションは追加しない（将来対応）

### Reviewer Profile: runtime

### ランタイム検証
- `pytest tests/test_api.py -v` — 期待: PASS
- `mypy src/api/` — 期待: PASS
```

## Effort Scoring

タスクは複雑度 0-5 でスコアリングされ、Worker のモデルが決まります：

| スコア | モデル | タスクタイプ |
|--------|--------|-------------|
| 0-1 | haiku (cheap) | 機械的: 明確な仕様、1-2ファイル |
| 2 | sonnet (standard) | 統合: 複数ファイル、判断が必要 |
| 3+ | opus (capable) | 設計: 複雑、横断的 |

スコアリング要因: ファイル数、ディレクトリリスク、キーワード、横断的関心事、新規サブシステム。

## 必要条件

- サブエージェント対応の Claude Code
- Git（worktree 隔離用）
- Node.js やその他のランタイム依存なし

## ライセンス

MIT
