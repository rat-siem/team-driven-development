# Language Policy File Scope Design

## Overview

Revise each `SKILL.md`'s `## Language Policy` block to fence file output: files written to disk stay English regardless of conversation language, and must follow Token Economy — inlined directly into the block so no external file lookup is required. Addresses an observed case where `quick-brainstorm`, invoked from a Japanese conversation, wrote a Japanese spec to `docs/team-dd/specs/` against the English-only source rule. Parallel one-paragraph rules are added to file-writing agents (`worker`, `sprint-master`), and `CLAUDE.md` / `guidelines/writing.md` are updated to explicitly treat skill-generated artifacts as source files.

## Motivation

- **Observed failure.** `quick-brainstorm` produced `docs/team-dd/specs/*-design.md` in Japanese from a Japanese conversation.
- **Root cause: local ambiguity, not missed global rule.** The current Language Policy block translates "user-facing prose" to the user's language but never fences file output — the LLM over-generalized "user-facing" to cover spec body. `CLAUDE.md` was already loaded and still did not prevent the drift.
- **Portability constraint blocks external references.** This plugin installs into `~/.claude/plugins/cache/…/` on end-user machines. At skill runtime, the cwd is the user's own project, where no `guidelines/writing.md` exists. A "see `guidelines/writing.md`" reference inside a SKILL.md would dangle for external users and could cause a runtime read error if the LLM attempts to follow the reference. A "read `CLAUDE.md`" reference is equally unsafe: the user's own `CLAUDE.md` is loaded in their session, not the plugin's.
- **Therefore, rules that must apply at runtime must be inlined** into the SKILL.md (and into every agent `.md` that writes files), shipped with the plugin itself.
- **Cross-file duplication is acceptable here.** The "don't restate the same rule twice" principle governs intra-file redundancy. Cross-file appearance — contributor-facing `guidelines/writing.md` plus runtime SKILL.md / agent `.md` blocks — is necessary because the two contexts are loaded by different audiences in different environments.

## Design

### Revised Language Policy block (all six SKILL.md)

All six `SKILL.md` files carry the identical Language Policy block. Replace the current single-paragraph version with a two-paragraph version: the first paragraph keeps the existing chat-prose rule verbatim; the second paragraph adds the file-output fence and an inlined Token Economy checklist.

New block:

````markdown
## Language Policy

Render user-facing prose (announce, gates, status, errors) in the user's language; explicit user request overrides. Keep literal: commands, paths, `<placeholders>`, backtick-wrapped identifiers (e.g., `PASS`, `DONE`), severity/disposition labels, status markers (📌🔍❓⚠), Markdown structure (headings, table column headers). Default to match recent user input; English if no signal.

Files written to disk (specs, plans, contracts, source code) stay English regardless of conversation language. Apply Token Economy to their contents:

- Omit what the LLM can infer from context or adjacent sections.
- Prefer shortest unambiguous phrasing. Tables/lists beat prose for enumerations.
- No filler transitions ("Next,", "In summary,", "It's important to note that").
- No rationale unless it changes behavior in edge cases.
- Don't restate the same rule twice within one file.
````

Apply identical wording to `quick-brainstorm`, `deep-brainstorm`, `team-plan`, `sprint-master`, `solo-review`, `team-driven-development` — including the three that don't write committed files directly. Uniformity simplifies maintenance; skills may evolve or dispatch file-writing agents later.

### File-output rule in file-writing agents

Subagents dispatched via the `Agent` tool run in fresh contexts. They do not inherit the dispatching SKILL.md's Language Policy block. For agents that write files, add a `## Output Language` section near the top of the agent's `.md` file — immediately after the role-definition paragraph, before the first functional section:

````markdown
## Output Language

Files you write stay English regardless of conversation language. Apply Token Economy to their contents:

- Omit what the LLM can infer from context.
- Tables/lists over prose for enumerations.
- No filler transitions.
- No rationale unless it changes behavior in edge cases.
````

Agents to update:

- `agents/worker.md` — writes source code in worktrees.
- `agents/sprint-master.md` — writes `sprints/<topic>/*.md`.

No change to `agents/reviewer.md` (emits verdicts consumed by Lead, not committed files) or `agents/architect.md` (emits design briefs consumed by Workers, not committed files).

### Clarify `CLAUDE.md`

Append one bullet to the `## Prompt Language Policy` section making skill-generated files explicit:

> - Files produced by skills at runtime — specs in `docs/team-dd/specs/`, plans in `docs/team-dd/plans/`, Sprint Contracts in `sprints/<topic>/`, and any source code a Worker writes — are source files too. They must be English.

### Clarify `guidelines/writing.md`

Tighten the existing "Source vs. runtime" note under `## Language` so contributors see that generated artifacts fall under the source-file rule:

> **Source vs. runtime.** Source files — including `SKILL.md` and anything a skill generates (specs, plans, Sprint Contracts, source code) — are English for tokenization and ambiguity reasons. At runtime, user-facing natural-language strings emitted by a skill (announce, gates, status, errors) must render in the user's conversation language — see the `## Language Policy` block inside each `SKILL.md`.

### Non-Goals

- **No external file-path references inside SKILL.md or agent `.md`.** The plugin installs into a cache outside the user's cwd. Relative paths like `guidelines/writing.md` would not resolve at skill runtime. All actionable rules are inlined.
- **No "read `CLAUDE.md` first" addition.** `CLAUDE.md` is only reliably loaded when this repo itself is the working directory; external users' sessions load their own `CLAUDE.md`. The observed failure happened with `CLAUDE.md` already loaded — the fix is local disambiguation, not a re-read directive.
- **Cross-file duplication is intentional.** The Token Economy checklist appears in every SKILL.md Language Policy block, in every file-writing agent's Output Language section, and in `guidelines/writing.md`. The intra-file "don't restate the same rule twice" principle is preserved within each file; cross-file appearance is required because each file is loaded in a different context by a different audience.
- **No change to runtime chat localization.** Announce, gates, status, and errors continue to render in the user's language per existing behavior.

### Testing Strategy

Markdown prompt changes are not unit-testable — validate manually.

- **Japanese spec generation (primary regression):** from a Japanese conversation, invoke `/team-driven-development:quick-brainstorm` with a Japanese topic. Verify announce and Spec Gate render in Japanese; verify the committed spec at `docs/team-dd/specs/YYYY-MM-DD-<topic>-design.md` is English throughout (headings, body, File Changes table) and free of TE violations (filler transitions, restated rules, unnecessary rationale).
- **Japanese plan generation:** continue into `team-plan`. Verify the plan file is English and tight.
- **Japanese contract generation:** continue to `sprint-master` dispatch. Verify `sprints/<topic>/common.md` and `task-N.md` are English and tight.
- **Japanese code generation:** in a Japanese-driven `team-driven-development` flow, verify source files a Worker writes (code, comments) are English.
- **English regression:** repeat the full flow in English. Verify announce, gates, and files all remain English — no behavioral change.

## File Changes

| File | Status | Purpose |
|---|---|---|
| `skills/quick-brainstorm/SKILL.md` | Modify | Replace Language Policy block with two-paragraph version including file fence + TE checklist |
| `skills/deep-brainstorm/SKILL.md` | Modify | Same |
| `skills/team-plan/SKILL.md` | Modify | Same |
| `skills/sprint-master/SKILL.md` | Modify | Same |
| `skills/solo-review/SKILL.md` | Modify | Same |
| `skills/team-driven-development/SKILL.md` | Modify | Same |
| `agents/worker.md` | Modify | Insert `## Output Language` section with file-output rule + TE checklist |
| `agents/sprint-master.md` | Modify | Same |
| `CLAUDE.md` | Modify | Add bullet to Prompt Language Policy clarifying skill-generated files are source files |
| `guidelines/writing.md` | Modify | Tighten Source vs. runtime note to explicitly include skill-generated artifacts |
| `docs/team-dd/specs/2026-04-18-language-policy-file-scope-design.md` | Modify | This spec — rewritten to reflect inlined rules and expanded scope |
