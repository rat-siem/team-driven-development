# README Quick Brainstorm Flow Fix Design

## Overview

`README.md` と `docs/README.ja.md` の "Usage → With Quick Brainstorm" セクションのフロー記法と説明文を修正し、`team-plan` を経由する現在の実装と一致させる。`team-plan` 導入時に追記が漏れた記述を補う。

## Motivation

- Key Features セクションでは `quick-brainstorm → team-plan → sprint-master → team-driven-development` と正しく説明されているのに対し、Usage セクションでは `/quick-brainstorm <task description> → team-driven-development` と記載されており `team-plan` が抜けている。
- 同じ Usage セクション内の説明文 "The `quick-brainstorm` skill generates a spec and plan with minimal dialogue." は実装と矛盾する。現在 `quick-brainstorm` が生成するのは spec のみで、plan は `team-plan` が生成する。
- Deep Brainstorm の Usage 項では既に `deep-brainstorm → team-plan → team-driven-development` と統一された記述になっているため、Quick Brainstorm 側の記述が局所的に不整合な状態。
- README は新規ユーザーが最初に読むドキュメントであり、Usage セクションの誤りはオンボーディング時の混乱と誤った期待値設定を招く。

## Design

### Scope

In scope:
- `README.md` の `Usage → With Quick Brainstorm (self-contained)` サブセクション（L163–L169 周辺）の修正。
- `docs/README.ja.md` の `使い方 → Quick Brainstorm と併用（自己完結）` サブセクション（L162–L168 周辺）の対応する修正。

Out of scope:
- Key Features セクションの記述（既に正しい）。
- Deep Brainstorm の Usage 項（既に正しい）。
- `How It Works` フェーズ説明、その他 Usage サブセクション（`Solo Review`, `Standalone`）。
- スキルファイル、`CLAUDE.md`、その他のドキュメント。

### Section-by-Section Changes

#### 1. `README.md` — `With Quick Brainstorm (self-contained)`

**Current:**

```
### With Quick Brainstorm (self-contained)

```
/quick-brainstorm <task description> → team-driven-development
```

The `quick-brainstorm` skill generates a spec and plan with minimal dialogue. When the plan is ready, it offers to hand off directly to team-driven-development for execution. If team-driven-development is invoked without a plan, it will suggest quick-brainstorm automatically.
```

**Updated:**

- フロー記法を `/quick-brainstorm <task description> → team-plan → team-driven-development` に変更。Deep Brainstorm の Usage 項と同じ詳細レベルに統一する（`sprint-master` は `team-plan` の内部呼び出しなのでフロー図には出さず、説明文側で言及）。
- 説明文を以下のニュアンスに書き換える：
  - `quick-brainstorm` が生成するのは spec のみであることを明示。
  - 承認された spec は `team-plan` に引き渡され、`team-plan` が plan を生成し、内部で `sprint-master` を呼び出して Sprint Contract ファイルを生成することを明示。
  - plan が確定したら team-driven-development への引き渡しが提案されることを明示。
  - "team-driven-development invoked without a plan, suggests quick-brainstorm" の挙動は維持（既存記述）。

#### 2. `docs/README.ja.md` — `Quick Brainstorm と併用（自己完結）`

英語版と1:1で対応する変更を、既存の語調（です・ます、技術用語は英語のまま）で適用する。

- フロー記法を `/quick-brainstorm <タスクの説明> → team-plan → team-driven-development` に変更。
- 説明文を更新：
  - `quick-brainstorm` は spec を生成する（plan ではない）。
  - 承認後 `team-plan` に渡り、plan 生成と `sprint-master` 呼び出しが行われる。
  - plan 完成後に team-driven-development への引き渡しが提案される。
  - plan なしで team-driven-development を呼んだ場合に quick-brainstorm が自動提案される挙動は維持。

### Wording Rules

- 既存の `Deep Brainstorm` Usage 項と表現粒度を揃える（同じレベルの省略・展開）。フロー図には `sprint-master` を含めず、説明文側で触れる。
- 既存の英日対応構造（同じ箇条書き数・段落順）を崩さない。
- スキル名を最初の登場時に明示し、以降は装飾なしで参照する既存スタイルを踏襲。

### Error Handling

なし — 静的なドキュメント編集のみ。

### Testing Strategy

- **目視確認**: 修正後の Usage セクションを通読し、Key Features の `quick-brainstorm → team-plan → sprint-master → team-driven-development` 表記、および Deep Brainstorm Usage 項の `deep-brainstorm → team-plan → team-driven-development` 表記と論理的に整合することを確認。
- **英日対応確認**: `README.md` と `docs/README.ja.md` の対応箇所を並べて、段落構造・記述順・含まれる事実が一致することを確認。
- **Sprint Contract 観点**: 静的レビュー（`static` プロファイル）で十分。実行・ブラウザ検証は不要。

## File Changes

| File | Status | Purpose |
| --- | --- | --- |
| `README.md` | Modify | `Usage → With Quick Brainstorm (self-contained)` サブセクションのフロー記法と説明文を修正。 |
| `docs/README.ja.md` | Modify | `使い方 → Quick Brainstorm と併用（自己完結）` サブセクションを英語版と一致させる。 |
| `docs/team-dd/specs/2026-04-18-readme-quick-brainstorm-flow-fix-design.md` | Create | This spec. |
| `docs/team-dd/plans/2026-04-18-readme-quick-brainstorm-flow-fix.md` | Create (by team-plan) | Implementation plan. |
| `sprints/2026-04-18-readme-quick-brainstorm-flow-fix/` | Create (by sprint-master) | Sprint Contract files, when executed. |
| Key Features セクション、Deep Brainstorm Usage 項、その他のセクション、スキル、`CLAUDE.md` | Not modified | Out of scope. |
