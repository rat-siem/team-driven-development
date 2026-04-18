# Consolidate Plan Gate and Execute Gate Design

## Overview

Merge `team-plan`'s two-step user interaction (plan-change gate + execute-or-not gate) into a single combined prompt that asks the user to either confirm execution with `team-driven-development` or request revisions. Align `quick-brainstorm`'s Execution Handoff block with the new pattern so the chain has a single source of truth for execution confirmation.

## Motivation

- Today `team-plan` emits two sequential prompts at the end of its flow: `Plan saved to <path>. Any changes before we proceed?` followed by `Execute with team-driven-development? [yes/no]`. When the user has no revisions — the common case — they must reply twice ("No changes" then "yes") to reach execution. This is unnecessary friction.
- Framing the first prompt around "are there changes?" inverts the desired default. The user most often wants to execute; treating the execute step as a separate question makes the flow feel gated.
- A single combined prompt lets the user answer once: plain confirmation proceeds to execution; any free-form reply is treated as revision intent and loops back to plan editing. Revisions remain fully supported.
- `quick-brainstorm` currently duplicates an Execution Handoff block that overlaps with `team-plan`'s. Consolidating the prompt in one place (owned by `team-plan`) removes the overlap and simplifies the chain.

## Design

### Merged Gate in team-plan

Replace the current separate `## User Plan Gate` and `## Execution Handoff` sections with a single `## Plan Confirmation Gate` section. The prompt asks one question: confirm execution or request revisions.

**Literal prompt text (English default; rendered in user's language per Language Policy):**

```
Plan saved to <path>. Ready to execute with team-driven-development? Reply to confirm, or describe any revisions to edit the plan first.
```

**Response handling:**

- **Plain affirmative** (e.g., `yes`, `go`, `execute`, `proceed`, `ok`, `lgtm`, or equivalent in the user's language) → invoke `team-driven-development`.
- **Plain negative / decline** (e.g., `no`, `stop`, `not now`, `cancel`) → stop. Do not invoke `team-driven-development`. The plan file stays on disk for later execution.
- **Any other response** (including free-form feedback, change requests, questions about the plan) → treat as revision intent. Revise the plan inline, re-run self-review, then re-emit the same gate prompt.

Interpretation is a judgment call by the LLM, not a keyword match. When genuinely ambiguous (one short word that could be either), ask one clarifying question (`Confirming execution, or did you mean something else?`) before acting.

### Checklist and Flow Updates in team-plan

- Collapse checklist steps 7 (`User confirms plan`) and 8 (`Propose execution`) into a single step 7: `Plan Confirmation Gate — revise on free-form feedback; execute on confirmation; stop on decline.`
- Update the Process Flow graph: replace the `User approves plan?` → `Propose execution` sequence with a single `Plan Confirmation Gate` diamond that branches to `Generate plan` (revise), `Invoke team-driven-development` (confirm), or `Stop` (decline).

### quick-brainstorm Alignment

`quick-brainstorm` currently has its own `## Execution Handoff` section (lines 150-158) that proposes execution after `team-plan` returns. With `team-plan` owning the combined gate, this block becomes redundant — `team-plan` will already have invoked `team-driven-development` (or stopped) before returning control.

Changes:

- Remove the `## Execution Handoff` section from `quick-brainstorm/SKILL.md`.
- Update checklist step 7 from `Propose execution — after team-plan returns and the plan is approved, offer team-driven-development handoff` to `Return — team-plan owns the combined plan/execute gate and completes the chain`.
- Update the Process Flow graph: the terminal node changes from `Propose execution` to `Hand off to team-plan` as `doublecircle`.
- Update line 148 from `team-plan owns plan generation, plan self-review, and the user plan gate` to `team-plan owns plan generation, plan self-review, and the combined plan/execute gate (including invocation of team-driven-development on confirmation)`.

### Standalone vs. Chained Invocation

The merged gate behaves identically whether `team-plan` is invoked directly by the user or as a handoff from `quick-brainstorm` / `deep-brainstorm`. There is no conditional branch based on caller. This is simpler than the current implicit split (where `team-plan` owns the plan gate and the caller owns the execution handoff) and removes the inconsistency between `team-plan`'s checklist (which always lists both steps) and `quick-brainstorm`'s claim that `team-plan` owns only the plan gate.

### sprint-master

`sprint-master/SKILL.md:31` already uses a single `Execute with team-driven-development? [yes/no]` prompt with no preceding "any changes?" step. No change needed. Its prompt wording is intentionally different (the sprint-master flow has no plan-edit step — contracts are generated by a subagent and are not expected to be revised in the same turn), so we do NOT unify the wording with `team-plan`.

### Language Policy Compliance

The new prompt text is English (SKILL.md source files remain English per plugin policy). At runtime, the Language Policy section in both skills already mandates rendering user-facing prose in the user's language. The merged prompt inherits this behavior — rendered literally when the user's language is English, translated otherwise. Placeholders (`<path>`), commands, and `team-driven-development` stay literal.

### Error Handling

- **User reply is ambiguous** (single token that doesn't clearly match confirm/decline/revise patterns): emit one clarifying question: `Confirming execution, or did you want to revise the plan?`. Do not act until the reply is unambiguous.
- **User confirms but `team-driven-development` invocation fails**: surface the error. The plan file stays on disk; user can retry via direct `/team-driven-development:team-driven-development <plan-path>` invocation.
- **User declines**: stop cleanly. No error. Echo `Plan left at <path>. Run /team-driven-development:team-driven-development <plan-path> to execute later.` so the user has the follow-on command.

### Testing Strategy

Manual verification against the two skills:

- **team-plan direct invocation**: run `/team-driven-development:team-plan <spec-path>`, confirm the merged prompt appears exactly once after self-review, confirm each of three response paths (confirm / decline / revise) reaches the correct next state.
- **quick-brainstorm → team-plan chain**: run `/team-driven-development:quick-brainstorm <request>`, confirm only two gates fire (spec gate + merged plan/execute gate), confirm no duplicate execution prompt from `quick-brainstorm`.
- **Grep assertions** (lightweight mechanical checks):
  - `grep -c 'Plan Confirmation Gate' skills/team-plan/SKILL.md` → expect ≥1
  - `grep -c 'User Plan Gate\|Execution Handoff' skills/team-plan/SKILL.md` → expect 0
  - `grep -c 'Execution Handoff' skills/quick-brainstorm/SKILL.md` → expect 0
  - `grep -c 'Any changes before we proceed' skills/team-plan/SKILL.md` → expect 0
- **Language policy sanity check**: confirm the prompt literal is English in the source file and the Language Policy section is unchanged.

## File Changes

| File | Status | Change |
| --- | --- | --- |
| `skills/team-plan/SKILL.md` | Modify | Replace `User Plan Gate` + `Execution Handoff` with `Plan Confirmation Gate`. Update checklist steps 7-8 → single step 7. Update Process Flow DOT graph. |
| `skills/quick-brainstorm/SKILL.md` | Modify | Remove `Execution Handoff` section. Update checklist step 7 and Process Flow DOT graph. Update line 148 ownership statement. |
| `skills/sprint-master/SKILL.md` | Not modified | Single-prompt flow already matches intent. |
| `skills/deep-brainstorm/SKILL.md` | Not modified | Does not use this prompt pattern. |
| `CLAUDE.md` | Not modified | No policy changes. |
| `docs/team-dd/specs/2026-04-18-consolidate-plan-execute-gate-design.md` | Create | This spec. |
