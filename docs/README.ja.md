# Team-Driven Development

[English](../README.md)

専門的な役割を持つサブエージェントチームで実装プランを実行する Claude Code プラグインです。

## アーキテクチャ

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

## スキル

すべてのスキルがこのプラグインに同梱されており、`/<skill-name>` で呼び出せます。スキルは2つのグループに分かれています：**コアパイプライン**（通常の機能実装で順に呼び出す）と、**補助スキル**（コアパイプラインが内部で自動的に利用するスタンドアロンツール。特定の状況でのみ直接呼び出す）。

#### コアパイプライン

通常の実行フローは、spec スキル → `team-plan` → `team-driven-development` の順です。

**Stage 1 — Spec 生成（いずれかを選ぶ）**

### quick-brainstorm

軽量な spec 生成スキル。リポジトリから推論できることは推論し、本当に曖昧な点のみ質問する。本格的な品質の spec を生成し、`team-plan` に引き渡す。スコープが明確なタスクの標準選択肢。`/quick-brainstorm <request>` で呼び出す。

### deep-brainstorm

3フェーズ（Distill / Challenge / Harden）の spec 生成スキル。Decision Log、Unresolved Items、Checklist Snapshot を含む拡張 spec を生成する。要件が曖昧、または判断の根拠を成果物として残したい場合に使用。`/deep-brainstorm <request>` で呼び出す。

### superpowers:brainstorming *(外部・任意)*

Superpowers プロジェクト自体のブレインストーミングスキル。spec のフォーマットが共通なので、このプラグインの `team-plan` とも互換。Superpowers エコシステムで作業している場合や、Superpowers の対話スタイルが好みの場合に使用。

**Stage 2 — Plan 生成**

### team-plan

`docs/team-dd/specs/` の承認済み spec を読み、`docs/team-dd/plans/` にトークン最適化された plan を出力する。plan 承認後、自動的に `sprint-master` を呼び出して Sprint Contract ファイルを生成する。`/team-plan <spec-path>` で呼び出す。

**Stage 3 — 実行**

### team-driven-development

オーケストレーションスキル。plan + Sprint Contracts に対して Lead / Worker / Reviewer / Architect の役割を動作させる。Reviewer のレビューも内部で実行されるため、このフロー内で `solo-review` を別途呼ぶ必要はない。Lite / Full モード対応（自動トリアージ、`--lite` / `--full` で強制可能）。Sprint Contract ファイルが無い場合は F4 ゲートから `sprint-master` を自動呼び出しする。`/team-driven-development <plan-path>` で呼び出す。

#### 補助スキル

これらはコアパイプラインが自動的に呼び出します。直接呼び出すのは以下の状況のみです。

### sprint-master

Sprint Contract 生成の唯一の所有者。spec + plan を読んで `docs/team-dd/sprints/<topic>/common.md` と `task-N.md` を書き出す。通常は `team-plan` が plan 承認後に呼び出すか、`team-driven-development` の F4 Sprints Gate が呼び出す。直接呼び出すのは以下のみ：

- 自前で手書きした plan に対して Sprint Contract ファイルを生成したい（`team-plan` をスキップする場合）、または
- Sprint Contract 生成後に plan を編集し、更新された plan に対して Contract を再生成したい場合。

呼び出し: `/sprint-master <spec-path> <plan-path>`。

### solo-review

Reviewer エージェントを単体で実行する。レビュー対象（ステージ済み / 未コミット / ブランチ diff）を自動検出し、基準（Sprint Contract → plan 派生 → 汎用）を適応させる。コアパイプラインは各 Worker の成果物を既にレビューしているため、`solo-review` は標準フローの一部 **ではない**。直接呼び出すのは以下のみ：

- 異なる観点で追加のレビューをしたい（例: `static` レビューの後に `--profile runtime` や `--profile browser` を強制）、
- `team-driven-development` が承認済みのコードを、新しい観点（セキュリティ、パフォーマンス、リファクタ可否）で再レビューしたい、
- 特定のコミット範囲やパスをレビューしたい（`/solo-review HEAD~3..HEAD`、`/solo-review src/api/`）、
- チームパイプライン外で書かれたコードをレビューしたい（手書きの変更、外部コントリビューション）、または
- 特定の Sprint Contract に対して明示的にレビューしたい（`--contract <path>`）。

呼び出し: `/solo-review [range|path] [--profile ...] [--contract ...]`。

#### 横断的な機能

スキルではないが、パイプライン全体に登場するエンジンレベルの機能：

- **Effort Scoring** — タスク複雑度に基づく Worker モデル自動選択（cheap / standard / capable）。
- **Worktree 隔離** — Worker は隔離された git worktree で作業。承認後にのみ main に反映。
- **Worktree 対応実行** — worktree 内からの呼び出しを自動検知し、sub-worktree と cherry-pick をスキップ。
- **Review Ledger** — 全指摘を disposition（fixed / deferred / wont-fix）付きで修正ラウンドにわたって追跡し、完了レポートに集約。
- **Domain Guidelines** — 欠けているドメインガイドラインを自動検知し、既存コードからドラフトを生成、承認後に Sprint Contract に組み込む。
- **Sprint Contract QA** — Worker 派遣前に Contract を検証（検証可能な基準、非目標、プロファイル一致）。
- **動的依存解析** — プラン内容から実行順序を実行時に決定。
- **並列実行** — 独立タスクを複数の Worker で同時実行。
- **3段階レビュー** — `static`（Lead が diff 確認）、`runtime`（エージェントがテスト実行）、`browser`（エージェント + UI 検証）。
- **適応的プロセス選択** — シンプルなプランは Lite Mode、複雑なプランは Full Mode。`--lite` / `--full` でオーバーライド可能。

## スキルの選び方

**エントリーポイント判定**

```
手元にあるものは？
├── ざっくりしたアイデア、スコープ明確       → /quick-brainstorm
├── 曖昧 / 影響の大きい要件                  → /deep-brainstorm
├── spec がすでにある（自作 or Superpowers） → /team-plan <spec>
└── plan がすでにある（+ Sprint Contracts）  → /team-driven-development <plan>
```

**コアパイプライン — 通常の作業で使い分けるスキル**

| 状況 | 使うスキル | 出力 | 次のステップ |
|---|---|---|---|
| 明確な依頼があり、素早く spec が欲しい | `quick-brainstorm` | spec | `team-plan` |
| 曖昧 / 影響の大きい要件 | `deep-brainstorm` | Decision Log 付き拡張 spec | `team-plan` |
| Superpowers エコシステムで作業中 | `superpowers:brainstorming` | Superpowers 形式の spec | `team-plan`（互換） |
| 承認済み spec がある | `team-plan` | plan + Sprint Contracts（`sprint-master` 経由） | `team-driven-development` |
| plan と Sprint Contracts がある | `team-driven-development` | 実装・レビュー済みコード | — |

`quick-brainstorm` と `deep-brainstorm` で迷ったら、まず `quick-brainstorm` を選ぶ — エスカレーションが必要な曖昧さは `quick-brainstorm` 自体が露出させる。このプラグインのブレインストーミングスキルと `superpowers:brainstorming` で迷ったら、どちらでも動く — 慣れている方を選ぶ。

**補助スキル — 以下の状況でのみ呼び出す**

| 状況 | 使うスキル | なぜコアパイプラインではないか |
|---|---|---|
| 手書きの plan に Sprint Contracts が必要 | `sprint-master` | `team-plan` は自身が出力した plan に対して Contract を自動生成する。`team-plan` をスキップする場合のみ自分で `sprint-master` を呼ぶ。 |
| Sprint Contract 生成後に plan を編集した | `sprint-master` | 更新された plan に対して Contract を再生成する。 |
| `team-driven-development` 承認後に異なる観点で追加レビューしたい | `solo-review --profile <runtime\|browser>` | コアパイプラインは各タスクを Contract に照らしてレビューする。`solo-review` はその上に新たな観点で追加レビューを重ねる。 |
| パイプライン外のコードをレビュー（手書き、外部 PR 等） | `solo-review` | コアパイプラインは Worker の成果物しかレビューしない。 |
| 特定の範囲やパスだけをオンデマンドでレビュー | `solo-review HEAD~3..HEAD` / `solo-review src/api/` | 的を絞ったアドホックレビュー。 |
| 特定の Sprint Contract を現在の変更に対して強制したい | `solo-review --contract <path>` | チームフロー外で、明示的な Contract を使って Reviewer を実行。 |

## ワークフロー

```
  spec                  plan                        execution
    │                     │                             │
quick-brainstorm ───►  team-plan  ──────────────►  team-driven-development
deep-brainstorm   ───►     │                             │
superpowers:      ───►     │                             │
  brainstorming            │                             │
                           ▼                             │
                     sprint-master                       │
               （自動: team-plan と                      │
                team-driven-development の               │
                F4 Sprints Gate から呼ばれる）           │
                                                         ▼
                                                （Reviewer は
                                                 team-driven-development
                                                 の内部で動作）

  パイプライン外、手動のみ:
    sprint-master  — 手書きの plan、または Contract 生成後の plan 編集時
    solo-review    — 追加観点のレビュー、パイプライン外コード、特定範囲/パス
```

spec は `docs/team-dd/specs/`、plan は `docs/team-dd/plans/`、Sprint Contract は `docs/team-dd/sprints/<topic>/` に保存される。各ステージには所有者が1つ存在する：spec は `quick-brainstorm` / `deep-brainstorm`、plan は `team-plan`、Sprint Contract は `sprint-master`、実行は `team-driven-development`。Reviewer は `team-driven-development` の **内部** で動作する — `solo-review` はパイプラインのステージではない。

## 使い方

すべてのスキルがこのプラグインに同梱されています。spec と plan のフォーマットは Superpowers と共通なので、`superpowers:brainstorming` や `writing-plans` のスキルとも相互運用できます。

### コアパイプライン

#### 標準フロー（quick）

```
/quick-brainstorm <request>     # spec を生成
→ spec を承認
→ team-plan 実行                 # plan を生成し、その後 sprint-master を自動呼び出し
→ plan を承認
→ team-driven-development 実行   # plan を実行。Reviewer は内部で動作
```

`quick-brainstorm` は承認済み spec を `team-plan` に引き渡します。`team-plan` は自動的に `sprint-master` を呼び出して Sprint Contract ファイルを生成します。`team-driven-development` は Worker を派遣し、各 Sprint Contract に対して Reviewer を実行します — 別途レビューステップは不要です。

#### じっくりフロー（deep / Superpowers）

```
/deep-brainstorm <request> → team-plan → team-driven-development
# または
superpowers:brainstorming → team-plan → team-driven-development
```

曖昧または影響の大きい要件で、複数アプローチ比較や Decision Log 保存が必要なら `deep-brainstorm` を使用します。Superpowers の `brainstorming` で作成された spec は spec フォーマットが共通なので、そのまま `team-plan` に流れます。

#### 自前の plan を持ち込む

team-plan のタスク形式で plan を書いたら、`team-driven-development` を直接呼び出します：

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

Sprint Contract ファイルが無い場合、`team-driven-development` の F4 Sprints Gate が `sprint-master` を自動呼び出しします。先に自分で `sprint-master` を実行することも可能です。

### 補助スキル（手動）

#### Sprint Contract の再生成（`sprint-master`）

`sprint-master` を直接呼び出すのは次の2状況のみ：(1) 自前で手書きした plan があり `team-plan` をスキップする、(2) Sprint Contract 生成後に plan を編集し、Contract を再生成したい。

```
/sprint-master <spec-path> <plan-path>
```

#### アドホックレビュー（`solo-review`）

コアパイプラインは各 Worker の成果物を既にレビューしています。`solo-review` はそれ以外の状況（追加観点、パイプライン外コード、特定範囲/パス、プロファイル強制、明示的な Contract）で使います。

```
/solo-review                                      # 現在の変更を自動検出
/solo-review HEAD~3..HEAD                         # 特定のコミット範囲
/solo-review src/api/                             # 特定のパス
/solo-review --profile runtime                    # runtime 検証を強制
/solo-review --contract path/to/contract.md       # 特定の Sprint Contract を使用
```

`solo-review` はレビュー基準を自動検出します：

- **Sprint Contract あり?** → 契約ベースレビュー（`team-driven-development` と同一）
- **plan ファイルあり?** → 該当する plan タスクから基準を導出
- **どちらも無い?** → 汎用コードレビュー（セキュリティ、正確性、テストカバレッジ）

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
4. ユーザーが拒否 or Quick Score > 1 → Phase A-0.5（Full Mode）へ

### Phase A-0.5: スプリントゲート (F4)
1. プランに対応する `docs/team-dd/sprints/<topic>/` ディレクトリの存在を確認
2. 存在する場合 → Phase A へ進む
3. 存在しない場合 → `docs/team-dd/sprints/<topic>/ not found. Run sprint-master now? [yes/no]` を提示
4. `yes` の場合 → `/team-driven-development:sprint-master <spec-path> <plan-path>` を呼び出し、成功後 Phase A へ
5. `no` の場合 → Sprint Contract ファイルの生成を促すか `--lite` 指定を案内して中断
6. Lite Mode はこのゲートをスキップ

### Phase A: 事前分析（Full Mode）
1. プランからすべてのタスクを読み取り・抽出
2. `docs/team-dd/sprints/<topic>/common.md` と各 `task-N.md` を読み込む（これらは権威的ソース。再生成しない）
3. 依存関係を動的に解析
4. チーム構成を決定

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

## 必要条件

- サブエージェント対応の Claude Code
- Git（worktree 隔離用）
- Node.js やその他のランタイム依存なし

## ライセンス

MIT
