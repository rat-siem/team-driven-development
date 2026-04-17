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
- **Reviewer** — Sprint Contract に基づいてエビデンス付きチェックリストで作業を検証。`static`、`runtime`、`browser` の3プロファイル。
- **Architect** — 設計判断が必要なタスクのみ召集。Worker 向けの Design Brief を出力。

## このプラグインを使う理由

- **コードを書く人とレビューする人が別。** Worker と Reviewer は別エージェント・別コンテキストで動く。単一エージェントが自分の成果物を検証するセルフレビューのバイアスを構造的に排除する。
- **作業開始前に成功条件が確定する。** Sprint Contract が「完了」の定義をコードを書く前にロックする。スコープのブレ、基準の後出し、「まあ良さそう」レビューが発生しない。
- **レビュー指摘がすべて追跡される。** Review Ledger が全指摘を修正ラウンドにわたって disposition（fixed / deferred / wont-fix）付きで記録する。指摘が暗黙的にドロップされることがない。
- **main ブランチが常に安全。** Worker は隔離された git worktree で作業する。変更はレビュー承認 + cherry-pick を経てのみ main に到達する — 失敗したタスクが作業ツリーを汚染しない。
- **トークンコストがタスク複雑度に連動する。** Effort Scoring がシンプルなタスクには安価なモデル（Haiku）、複雑なタスクには高性能モデル（Opus）を自動選択する。変数リネームに Opus の料金を払わなくて済む。
- **独立タスクが並列実行される。** 動的依存解析が同時実行可能なタスクを特定し、複数の Worker を別々の worktree で並列ディスパッチする。

## 向かないケース

このプラグインはオーケストレーションのオーバーヘッドを伴う。複雑な作業ではそのコストを上回る価値があるが、シンプルなタスクではコストの方が大きい。

**よりシンプルな方法を使うべき場面：**

- **単一ファイルの変更** — 1ファイルのバグ修正や設定変更にチーム・Sprint Contract・worktree は不要。
- **素早いプロトタイピング / 探索** — 試行錯誤してコードを捨てる前提のとき、契約→レビューのサイクルは無益な減速になる。
- **3ステップ未満のタスク** — プランが1〜2個の単純なタスクなら、トリアージのオーバーヘッド（Lite Mode でも）がロール分離の価値を上回る。
- **テストや検証ができない作業** — Sprint Contract は検証可能な成功条件に依存する。純粋に主観的な作業（コピーライティング、ビジュアル調整）では、レビュープロセスが検証する対象がない。
- **逐次的なインタラクティブ制御が必要** — チームワークフローは設計上セミオートノマス。1行ごとに承認したい場合は、直接実装の方が速い。

**目安：** 変更内容を一文で説明でき、対象ファイルが2つ以下なら、このプラグインはスキップしてよい。

## 主な機能

- **Quick Brainstorm** — 最小限の対話で本格的な spec + plan を生成する軽量スキル。コンテキストから推論できることは推論し、本当に曖昧な点のみ質問する。引き渡しは `quick-brainstorm → team-plan → sprint-master → team-driven-development`。`/quick-brainstorm` で呼び出すか、plan なしで team-driven-development を呼ぶと自動提案される。
- **Deep Brainstorm** — 曖昧または影響の大きい要件向けの厳密な3フェーズ版（Distill / Challenge / Harden）。Decision Log、Unresolved Items、Checklist Snapshot を含む拡張 spec を生成。判断の根拠を spec に残したい場合に `/deep-brainstorm` を使用。
- **Team Plan** — プラグイン内蔵の実装プラン生成器。`docs/team-dd/specs/` の承認済み spec を読み、`docs/team-dd/plans/` にトークン最適化された plan を出力したのち、`sprint-master` を呼び出して Sprint Contract ファイルを生成する。`/team-plan <spec-path>` で呼び出す。
- **Sprint Master** — Sprint Contract 生成の唯一の所有者。spec と plan から `sprints/<topic>/common.md` と `task-N.md` を書き出す。`team-plan` が plan 生成後に呼び出すほか、`/sprint-master <spec-path> <plan-path>` で直接呼び出し、または team-driven-development の F4 Sprints Gate から呼び出される。
- **Solo Review** — Reviewer エージェントによる単体コードレビュー。レビュー対象を自動検出（ステージ済み、未コミット、ブランチ diff）し、基準を適応（Sprint Contract → プラン派生 → 汎用）して構造化された判定を出力。`/solo-review` でフルチームワークフローなしにレビューを実行。
- **適応的プロセス選択** — シンプルなプランには Lite Mode を提案、複雑なプランにはフルチームプロセスを使用。`--lite` / `--full` でトリアージをスキップしてモードを直接選択可能。
- **動的チーム編成** — タスクの複雑度と種類に応じてロールを割り当て
- **Sprint Contract** — 作業開始前に成功条件・非目標・レビュープロファイルを定義
- **Effort Scoring** — タスク複雑度に基づくモデル自動選択（cheap/standard/capable）
- **Worktree 隔離** — Worker は隔離された worktree で作業。承認後にのみ main に反映
- **Worktree 対応実行** — git worktree の中から呼び出された場合を自動検知。Worker が現在のブランチに直接コミットするよう切り替え、sub-worktree の作成と cherry-pick をスキップ
- **動的依存解析** — プラン内容（ファイルパス、import、論理的依存）から実行順序を決定
- **並列実行** — 独立したタスクは複数の Worker で同時実行
- **3段階レビュー** — `static`（Lead が diff 確認）、`runtime`（エージェントがテスト実行）、`browser`（エージェント + UI 検証）
- **Review Ledger** — 全指摘を disposition（fixed/deferred/wont-fix）付きで追跡し、完了レポートに集約
- **Sprint Contract QA** — Worker 派遣前に Contract を検証（検証可能な基準、非目標、プロファイル一致）
- **Domain Guidelines** — プロジェクトにドメイン固有のガイドライン（フロントエンド、バックエンド、ライティング、テスト）がない場合を自動検知し、既存コードからドラフトを生成。承認されたガイドラインは Sprint Contract に組み込まれ、Worker は制約として従い、Reviewer は準拠をチェック。

## 動作フロー

### Phase 0: ガイドラインチェック
1. プランが触れるドメインを検知（ディレクトリパターンマッチング + Lead のフォールバック判断）
2. 各ドメインの `guidelines/{domain}.md` の存在を確認
3. 未存在かつ新規ファイル作成 or 同一ドメイン3ファイル以上変更 → 既存コードまたはテンプレートからドラフト生成
4. ユーザーが承認・編集 → 以降の Sprint Contract でガイドラインを使用

### Phase A-0: トリアージ
0. **Worktree チェック** — git worktree の中から実行されているか検知。該当する場合は Worktree Mode に切り替え：Worker が現在のブランチに直接コミット（sub-worktree・cherry-pick なし）。クリーンな作業ツリーが必要。
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
6. **Contract QA** — 各 Contract を検証（検証可能な基準、テストコマンド、非目標、プロファイル一致、依存関係の前提条件）
7. チーム構成を決定

### Phase B: 実行（タスクごと）
1. Architect を派遣して Design Brief を取得（必要な場合のみ）
2. Worker を隔離 worktree に派遣
3. Sprint Contract に基づいて**エビデンステーブル**でレビュー（各基準に MET/NOT_MET + エビデンス）
4. REQUEST_CHANGES の場合は修正ループ（最大3回）— 全指摘を **Review Ledger** で disposition 付き追跡
5. APPROVE で main に cherry-pick（コンフリクト時は解決フローあり）

### Phase C: 完了処理
1. 全結果を収集
2. **完了レポート**を生成（実装サマリー・テスト結果・タスクごとのレビュー詳細・指摘と disposition・deferred 理由を含む）
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

### Quick Brainstorm と併用（自己完結）

```
/quick-brainstorm <タスクの説明> → team-driven-development
```

`quick-brainstorm` スキルは最小限の対話で spec と plan を生成します — superpowers への依存なし。plan が完成すると team-driven-development への引き渡しを提案します。plan なしで team-driven-development を呼び出した場合は、自動的に quick-brainstorm を提案します。

### Solo Review（単体レビュー）

```
/solo-review
```

フルチームワークフローなしで現在の変更をレビューします。レビュー対象と基準を自動検出します：

- **Sprint Contract あり?** → 契約ベースレビュー（team-driven-development と同一）
- **プランファイルあり?** → 該当するプランタスクから基準を導出
- **どちらもなし?** → 汎用コードレビュー（セキュリティ、正確性、テストカバレッジ）

オーバーライドオプション：
```
/solo-review HEAD~3..HEAD              # 特定のコミット範囲
/solo-review src/api/                  # 特定のパス
/solo-review --profile runtime         # ランタイム検証を強制
/solo-review --contract path/to/contract.md  # 特定の Sprint Contract を使用
```

### Superpowers と併用（じっくり）

```
brainstorming → team-plan → team-driven-development
```

深い探索が必要なタスク — 複数アプローチの比較、セクションごとの設計承認、ビジュアルモックアップ — には `deep-brainstorm` スキルを使用してください。承認済み spec から `team-plan` スキルが実装プランを出力します。役割分担が効果的な複雑なプランで Team-Driven Development を実行方法として選択してください。

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

## 設計ノート: 委任時の意図的な YAGNI 違反

quick-brainstorm の質問フェーズでユーザーが判断を委任した場合（「どっちでもいい」「おまかせ」等）、このスキルは意図的に YAGNI 原則に違反します。最小限/保守的な選択肢を選ぶ代わりに、すべての潜在的要件を包括的に満たす最善のアプローチを選択します — 最小解釈よりもスコープが広がる場合であっても。

これは明確かつ意図的な設計判断です。理由：ユーザーが判断を委任するとき、エージェントに最強の設計を期待しています。ギャップを残す狭いプランは、エッジケースをカバーするやや広いプランよりも劣ります。委任された判断とその理由は、透明性のため spec に記録されます。

このルールは委任された判断にのみ適用されます。ユーザーが明確に指定した場合は、その指定が常に尊重され、YAGNI が通常通り適用されます。

## 必要条件

- サブエージェント対応の Claude Code
- Git（worktree 隔離用）
- Node.js やその他のランタイム依存なし

## ライセンス

MIT
