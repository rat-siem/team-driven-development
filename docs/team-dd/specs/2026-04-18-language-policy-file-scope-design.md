# Language Policy File Scope Design

## Overview

Insert a single-sentence file-scope fence into each `SKILL.md`'s `## Language Policy` block: files written to disk stay English and follow `guidelines/writing.md` Token Economy, even when chat output is localized. Addresses an observed case where `quick-brainstorm`, invoked from a Japanese conversation, wrote a Japanese spec to `docs/team-dd/specs/` against the `CLAUDE.md` English-only source rule.

## Motivation

- Observed failure: `quick-brainstorm` produced `docs/team-dd/specs/*-design.md` in Japanese from a Japanese conversation.
- `CLAUDE.md` and `guidelines/writing.md` already mandate English for repo files; the rule was not respected.
- The current Language Policy block translates "user-facing prose" to the user's language but never fences off file output — the LLM over-generalized "user-facing" to cover spec body.
- A "read `CLAUDE.md` first" instruction (originally proposed) would not fix this: the main agent already has `CLAUDE.md` loaded by the harness. Root cause is local ambiguity inside the Language Policy block, not a missed global rule.
- Token Economy applies to the same generated files and has the same generation-time visibility gap. Anchoring both rules from one fence avoids duplicating either rule's contents across skills — which would itself violate Token Economy.

## Design

### Insert file-scope fence sentence

All six `SKILL.md` files carry the identical one-paragraph Language Policy block. Insert one sentence between the existing first and second sentence; leave everything else untouched.

Current block:

> Render user-facing prose (announce, gates, status, errors) in the user's language; explicit user request overrides. Keep literal: commands, paths, `<placeholders>`, backtick-wrapped identifiers (e.g., `PASS`, `DONE`), severity/disposition labels, status markers (📌🔍❓⚠), Markdown structure (headings, table column headers). Default to match recent user input; English if no signal.

After insertion:

> Render user-facing prose (announce, gates, status, errors) in the user's language; explicit user request overrides. Files written to disk (specs, plans, contracts, source code) stay English and follow Token Economy per `guidelines/writing.md`. Keep literal: commands, paths, `<placeholders>`, backtick-wrapped identifiers (e.g., `PASS`, `DONE`), severity/disposition labels, status markers (📌🔍❓⚠), Markdown structure (headings, table column headers). Default to match recent user input; English if no signal.

Position (second sentence) places the fence immediately adjacent to the translation rule it bounds. One sentence carries two canonical rule references — no restatement, no duplication.

### Apply uniformly to all six skills

Use identical wording across `quick-brainstorm`, `deep-brainstorm`, `team-plan`, `sprint-master`, `solo-review`, `team-driven-development` — including the three that do not write committed files directly (`sprint-master`, `solo-review`, `team-driven-development`). One canonical block, no per-skill drift.

### Non-Goals

- **No "read `CLAUDE.md` first" addition** — `CLAUDE.md` is already auto-loaded by the harness; a re-read would not have prevented the observed failure.
- **No changes to `agents/*.md`** — subagents inherit `CLAUDE.md` from the project root and carry no Language Policy block pulling them toward localized output, so they are not at the same risk as skills. Revisit only if a subagent-side failure is observed.
- **No changes to `guidelines/writing.md` or `CLAUDE.md`** — the canonical English-source and Token Economy rules already exist there; the fix is local to where the Language Policy block creates ambiguity.
- **No restatement of Token Economy content** — the fence sentence references `guidelines/writing.md` rather than inlining TE's rules, per TE's own "pick one canonical location" principle.
- **No change to runtime chat localization** — announce, gates, status, and errors continue to render in the user's language per existing behavior.

### Testing Strategy

Markdown prompt changes are not unit-testable — validate manually.

- **Japanese spec generation (primary):** from a Japanese conversation, invoke `/team-driven-development:quick-brainstorm` with a Japanese topic. Verify announce and Spec Gate render in Japanese; verify the committed spec at `docs/team-dd/specs/YYYY-MM-DD-<topic>-design.md` is English throughout (headings, body, File Changes table).
- **Japanese plan generation:** continue the Japanese flow into `team-plan`. Verify the plan file is English.
- **Japanese contract generation:** continue to `sprint-master` dispatch. Verify `sprints/<topic>/common.md` and `task-N.md` are English.
- **Token Economy smoke check (qualitative):** skim each generated file for TE violations — filler transitions, restated rules, unnecessary rationale, prose where tables/lists would be tighter. Expected: none.
- **English regression:** repeat the full flow in English. Verify announce, gates, and files all remain English — no behavioral change.

## File Changes

| File | Status | Purpose |
|---|---|---|
| `skills/quick-brainstorm/SKILL.md` | Modify | Insert file-scope fence sentence into Language Policy block |
| `skills/deep-brainstorm/SKILL.md` | Modify | Same |
| `skills/team-plan/SKILL.md` | Modify | Same |
| `skills/sprint-master/SKILL.md` | Modify | Same |
| `skills/solo-review/SKILL.md` | Modify | Same |
| `skills/team-driven-development/SKILL.md` | Modify | Same |
| `docs/team-dd/specs/2026-04-18-language-policy-file-scope-design.md` | Create | This spec |
