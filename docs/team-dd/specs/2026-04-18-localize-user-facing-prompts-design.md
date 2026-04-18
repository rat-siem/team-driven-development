# Localize User-Facing Skill Prompts Design

## Overview

Make the fixed natural-language prompts emitted by the team-driven-development skills (announce lines, gate prompts, status/progress reports, user-facing error messages) render in the user's conversation language by default, or in an explicitly specified language. Source files stay English (authoring rule); runtime output matches the user (behavioral rule).

## Motivation

- Today every SKILL.md in this plugin contains English-literal user-facing strings — e.g., `team-plan` asks `Plan saved to <path>. Any changes before we proceed?` regardless of the user's language.
- When the preceding conversation is in Japanese (or any non-English language), the skill abruptly switches to English at each gate, which is jarring and breaks flow.
- The repo policy "all source files in English" (see `guidelines/writing.md` and `CLAUDE.md`) is an authoring rule about tokenization and ambiguity. It is not intended to constrain the language the LLM emits *at runtime* when speaking to the user.
- Users expect continuity: if they are speaking Japanese, the skill should too.

## Design

### Scope — what must be localized

In-scope (render in the user's language):

- Announce sentences — every `**Announce at start:**` line across skills.
- Gate prompts — every user-confirmation prompt:
  - `quick-brainstorm` User Spec Gate and Execution Handoff block.
  - `team-plan` User Plan Gate and Execution Handoff.
  - `sprint-master` "Execute with team-driven-development?" prompt.
  - `deep-brainstorm` "Spec committed ... Review and let me know ..." prompt and the Surfaced Concern "Add to checklist? (**Add / Decline / Defer**)" question.
  - `team-driven-development` F4 sprints gate (`sprints/<topic>/ not found. Run sprint-master now? [yes/no]`), Lite Mode proposal, worktree-cleanup prompt (`Clean up all? [Yes / No / Select]`).
- Status / progress reports surfaced to the user — e.g., `solo-review`'s "Reviewing [staged changes] (N files changed)", "Reviewer profile: ... (reason)", `team-driven-development`'s "Task N/Total complete — [task name]", "Running in worktree context."
- User-facing error / usage messages — e.g., `team-plan`'s "Spec file not found: <path>", `sprint-master`'s `Usage: /team-driven-development:sprint-master <spec-path> <plan-path>`, `team-driven-development`'s "Commit or stash changes first." and the F4 abort message.
- Closing lines of `solo-review` ("Review passed — no blocking issues found." / "Review found issues that need attention. ...").

Out-of-scope (keep literal in every language):

- Shell commands, slash commands (e.g., `/team-driven-development:team-plan <spec-path>`), Git commands.
- File paths, directory names, glob patterns (`sprints/<topic>/`, `docs/team-dd/plans/...`).
- Placeholder variables inside angle brackets (`<path>`, `<N>`, `<spec-path>`) — preserved verbatim so the downstream substitution continues to work.
- Machine-parsable identifiers used by the Reviewer/Worker protocols: `PASS`, `CHANGES_REQUESTED`, `APPROVE`, `REQUEST_CHANGES`, `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED`, `MET`, `NOT_MET`, `N/A`, severity labels (`critical`, `major`, `minor`, `nit`), disposition labels (`fixed`, `deferred`, `wont-fix`).
- Status-line markers: 📌 🔍 ❓ ⚠ (and the literal bracketed prefix `[Phase N <name> | Unresolved: ... | Added: ...]`).
- Markdown section headings used as structural anchors (e.g., `## Completion Report`, `## Review Ledger`, `### Implementation Summary`, `### Task N: <name>`) and the column headers of report tables — these are consumed by Reviewers/Lead pattern-matching.
- Frontmatter, filenames, committed artifact paths (specs under `docs/team-dd/specs/`, plans under `docs/team-dd/plans/`). Those remain English per the existing source-language rule.

### Policy Wording (canonical block)

A short "Language Policy" block, identical across skills, is inserted into each SKILL.md. Wording is tightened per `guidelines/writing.md` Token Economy:

````markdown
## Language Policy

Render user-facing prose (announce, gates, status, errors) in the user's language; explicit user request overrides. Keep literal: commands, paths, `<placeholders>`, backtick-wrapped identifiers (e.g., `PASS`, `DONE`), severity/disposition labels, status markers (📌🔍❓⚠), Markdown structure (headings, table column headers). Default to match recent user input; English if no signal.
````

### Placement in each SKILL.md

Insert the Language Policy block immediately after the `**Announce at start:**` line (and after any `<HARD-GATE>` block if present), and before `## Checklist`. This position is early enough for the LLM to apply the rule to the first announce emission, and stays with other meta-instructions rather than interleaving with procedural steps.

Skills to modify:

- `skills/quick-brainstorm/SKILL.md`
- `skills/deep-brainstorm/SKILL.md`
- `skills/team-plan/SKILL.md`
- `skills/sprint-master/SKILL.md`
- `skills/solo-review/SKILL.md`
- `skills/team-driven-development/SKILL.md`

Self-contained per skill rather than shared via a reference file: skills load independently when invoked; a shared file would not be auto-loaded, so each skill must carry the rule itself. The block is three short paragraphs — acceptable under this plugin's "quality over tokens" preference.

### Guidelines note

`guidelines/writing.md` currently has a `## Language` section that says "all `.md` files in this repo: English" — an authoring rule. Add a short subsection to distinguish the authoring rule from the runtime behavior so future skill authors are not confused:

> **Source vs. runtime.** Source files (including SKILL.md) are written in English for tokenization and ambiguity reasons. At runtime, user-facing natural-language strings emitted by a skill (announce, gates, status, errors) must render in the user's conversation language — see the Language Policy block inside each SKILL.md.

### Non-Goals

- No change to how specs, plans, Sprint Contracts, or agent prompts are authored — they stay English.
- No change to subagent-to-Lead internal protocols (Worker Status blocks, Reviewer verdicts). Those are machine-parsed, not user-facing.
- No localization of report headings (`## Completion Report`, `## Review Ledger`, table column names) — they are structural identifiers.
- No introduction of a language-selector CLI flag or config. Detection is inferred from conversation; override is by user request in natural language.

### Error Handling

- When translating a template containing `<placeholder>` tokens, the tokens are kept verbatim inside the translated sentence and the caller still substitutes them using the same replacement logic.
- If the conversation language cannot be inferred confidently on the first message (e.g., the user invokes with only a slash command and no prose), default to English for the first announce, then switch as soon as the user sends natural-language input.
- If the user mixes languages mid-session, match the language of the most recent natural-language turn. When truly ambiguous (equal mix), prefer the most recent explicit override; absent any override, prefer the language of the request that triggered the current skill invocation.

### Testing Strategy

Markdown skills are not unit-testable. Validate manually via representative flows.

- **Japanese flow (primary):** open a session in Japanese, invoke `/team-driven-development:quick-brainstorm` with a Japanese request. Verify:
  - quick-brainstorm announce line is Japanese.
  - Spec Gate prompt is Japanese with the `<path>` substituted literally.
  - team-plan announce line (on handoff) is Japanese.
  - Plan Gate prompt is Japanese.
  - Execution Handoff prompt is Japanese.
  - File paths, `/team-driven-development:...` commands, `<placeholder>` tokens, and identifiers (`PASS`, `DONE`, ...) remain literal.
- **English flow (regression):** same scenario in English. Verify all prompts stay English — no accidental translation of the phrasing.
- **Explicit override:** user types "reply in French" mid-session. Verify the next gate renders in French.
- **Identifier preservation:** induce a Reviewer REQUEST_CHANGES verdict in a non-English session. Verify `REQUEST_CHANGES`, severity labels, and `## Completion Report` remain literal, while the surrounding narration (e.g., solo-review's closing sentence) is localized.
- **Error path:** invoke `/team-driven-development:team-plan` with a missing spec path in Japanese. Verify the "Spec file not found: <path>" error message is rendered in Japanese, with the path token substituted literally.

## File Changes

| File | Status | Purpose |
|---|---|---|
| `skills/quick-brainstorm/SKILL.md` | Modify | Insert Language Policy block after Announce + HARD-GATE |
| `skills/deep-brainstorm/SKILL.md` | Modify | Insert Language Policy block after Announce + HARD-GATE |
| `skills/team-plan/SKILL.md` | Modify | Insert Language Policy block after Announce + HARD-GATE |
| `skills/sprint-master/SKILL.md` | Modify | Insert Language Policy block after Announce |
| `skills/solo-review/SKILL.md` | Modify | Insert Language Policy block after Announce |
| `skills/team-driven-development/SKILL.md` | Modify | Insert Language Policy block after Announce |
| `guidelines/writing.md` | Modify | Add "Source vs. runtime" note under `## Language` |
| `docs/team-dd/specs/2026-04-18-localize-user-facing-prompts-design.md` | Create | This spec |
