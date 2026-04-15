# Prompt Language Policy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert CLAUDE.md from mixed Japanese/English to fully English and add a Prompt Language Policy section.

**Architecture:** Single-file edit to CLAUDE.md — translate three Japanese sections and append a new policy section.

**Tech Stack:** Markdown only.

---

### Task 1: Translate CLAUDE.md Japanese sections to English

**Files:**
- Modify: `CLAUDE.md`

**Context:** The current CLAUDE.md has three sections with Japanese text. Here is the current content and the exact replacements needed.

- [ ] **Step 1: Replace the Overview section**

Change the Overview body from Japanese to English. Replace:

```markdown
## Overview

Lead/Worker/Reviewer/Architect の役割分担でサブエージェントを駆動する実装プラグイン。
Superpowers の `writing-plans` で作成されたプランをチーム構成で実行する。
```

With:

```markdown
## Overview

An implementation plugin that drives sub-agents through Lead/Worker/Reviewer/Architect role assignments.
Executes plans created by the Superpowers `writing-plans` skill using a team composition.
```

- [ ] **Step 2: Replace the Architecture section**

Change the Architecture bullet points from Japanese to English. Replace:

```markdown
## Architecture

- **Lead (コントローラー)**: チーム編成・タスク割当・統合・品質判断。コードは書かない。
- **Worker**: Worktree 隔離で実装 + TDD + セルフレビュー。
- **Reviewer**: Sprint Contract に基づくレビュー (static/runtime/browser)。
- **Architect**: 設計判断が必要なタスクのみ召集。
```

With:

```markdown
## Architecture

- **Lead (Controller)**: Team composition, task assignment, integration, and quality decisions. Does not write code.
- **Worker**: Implementation in isolated worktrees with TDD and self-review.
- **Reviewer**: Reviews based on Sprint Contracts (static/runtime/browser).
- **Architect**: Summoned only for tasks requiring architectural decisions.
```

- [ ] **Step 3: Replace the Design Principles section**

Change the Design Principles bullet points from Japanese to English. Replace:

```markdown
## Design Principles

- Superpowers の Plan 形式をそのまま使う（依存解析は Lead が動的に実行）
- Node.js/Go 非依存（シェルスクリプトのみ）
- Sprint Contract でレビュー基準を事前定義
- Effort Scoring でモデル選択を自動化
- Worktree 隔離 + Cherry-pick で main ブランチを保護
```

With:

```markdown
## Design Principles

- Uses the Superpowers Plan format as-is (dependency analysis is performed dynamically by the Lead)
- No Node.js/Go dependencies (shell scripts only)
- Review criteria pre-defined via Sprint Contracts
- Automated model selection through Effort Scoring
- Main branch protection via worktree isolation + cherry-pick
```

- [ ] **Step 4: Verify the translation**

Run: `grep -P '[\x{3040}-\x{309F}\x{30A0}-\x{30FF}\x{4E00}-\x{9FFF}]' CLAUDE.md`

Expected: No output (no Japanese characters remain in CLAUDE.md)

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: translate CLAUDE.md to English for token efficiency"
```

---

### Task 2: Add Prompt Language Policy section

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Append the Prompt Language Policy section**

Add the following section at the end of `CLAUDE.md`:

```markdown

## Prompt Language Policy

- All files in this plugin repository must be written in English.
- Exception: User-facing translation files (e.g., `docs/README.ja.md`).
- Rationale: English text uses fewer tokens than equivalent Japanese text (roughly 2-3x difference due to tokenizer behavior), and a single language across all agent-facing instructions reduces ambiguity.
```

- [ ] **Step 2: Verify final CLAUDE.md structure**

Run: `head -30 CLAUDE.md`

Expected output should show the complete file with these sections in order:
1. `# Team-Driven Development Plugin`
2. `## Overview` (English)
3. `## Architecture` (English)
4. `## Design Principles` (English)
5. `## Prompt Language Policy` (English, new)

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add prompt language policy to CLAUDE.md"
```
