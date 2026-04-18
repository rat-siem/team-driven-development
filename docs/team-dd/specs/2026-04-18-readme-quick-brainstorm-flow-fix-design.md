# README Quick Brainstorm Flow Fix Design

## Overview

Update `README.md` and `docs/README.ja.md` so the Quick Brainstorm flow notation and surrounding prose match the current implementation, which routes through `team-plan`. The `team-plan` step was added to the codebase but never propagated into these flow strings. At the same time, remove `sprint-master` from every flow chain in the READMEs — `sprint-master` is invoked internally as a subagent from `team-plan`, so it must not appear in user-facing flow notation. Manual invocation patterns (F4 Sprints Gate, direct `/sprint-master` call) and prose references to the skill are unaffected.

## Motivation

- The Usage section "With Quick Brainstorm (self-contained)" reads `/quick-brainstorm <task description> → team-driven-development`. The `team-plan` step is missing. The accompanying sentence "The `quick-brainstorm` skill generates a spec and plan with minimal dialogue." also contradicts the implementation: `quick-brainstorm` only generates a spec, and `team-plan` owns plan generation.
- The Key Features entry for Quick Brainstorm reads `quick-brainstorm → team-plan → sprint-master → team-driven-development`. The `team-plan` step is present here, but `sprint-master` should not be in the chain. The convention going forward is that flow notation lists only skills the user invokes manually; `sprint-master`, which `team-plan` calls as a subagent, belongs in prose, not in arrow chains.
- The Deep Brainstorm Usage entry already follows the desired convention (`deep-brainstorm → team-plan → team-driven-development`). Both Quick Brainstorm references currently diverge from that convention, creating a localized inconsistency.
- README is the first document new users read. Wrong flow notation in the most-trafficked sections produces onboarding confusion and false expectations about which steps require user action.

## Design

### Scope

In scope:
- `README.md`, two locations:
  - Key Features → Quick Brainstorm entry (around L59): fix flow notation.
  - Usage → "With Quick Brainstorm (self-contained)" subsection (around L163–L169): fix flow notation and rewrite the description.
- `docs/README.ja.md`, the two corresponding locations:
  - 主な機能 → Quick Brainstorm entry (around L58).
  - 使い方 → "Quick Brainstorm と併用（自己完結）" subsection (around L162–L168).

Out of scope:
- Other Key Features entries (Deep Brainstorm, Team Plan, Sprint Master, Solo Review, etc.).
- Deep Brainstorm Usage subsection — already follows the convention.
- "How It Works" phase descriptions — `sprint-master` references there are manual-invocation patterns (F4 Sprints Gate prompt, direct `/sprint-master` call) and are consistent with the convention.
- Other Usage subsections (Solo Review, Standalone).
- Prose mentions of `sprint-master` inside the Team Plan and Sprint Master Key Features entries — these are textual references describing skill behavior, not arrow-chain flow notation, and remain valid.
- Skill files, `CLAUDE.md`, marketplace.json, and any other files.

### Section-by-Section Changes

#### 1. `README.md` — Key Features `Quick Brainstorm` entry

**Current (L59):**

```
- **Quick Brainstorm** — Lightweight spec + plan generation with minimal dialogue. Infers what it can from context, asks only what's genuinely ambiguous, and outputs full-quality documents. Hands off via `quick-brainstorm → team-plan → sprint-master → team-driven-development`. Use `/quick-brainstorm` or let team-driven-development suggest it when no plan exists.
```

**Updated:**

- Change the flow chain to `quick-brainstorm → team-plan → team-driven-development` (drop `sprint-master`).
- Keep the rest of the entry intact (positioning, invocation hint, auto-suggest behavior).
- Optionally append a short prose note that `team-plan` invokes `sprint-master` internally to generate Sprint Contract files. Keep it brief; the dedicated Team Plan and Sprint Master entries already cover the detail.

#### 2. `README.md` — `Usage → With Quick Brainstorm (self-contained)`

**Current (L163–L169):**

```
### With Quick Brainstorm (self-contained)

```
/quick-brainstorm <task description> → team-driven-development
```

The `quick-brainstorm` skill generates a spec and plan with minimal dialogue. When the plan is ready, it offers to hand off directly to team-driven-development for execution. If team-driven-development is invoked without a plan, it will suggest quick-brainstorm automatically.
```

**Updated:**

- Change the flow chain to `/quick-brainstorm <task description> → team-plan → team-driven-development`. Match the granularity of the Deep Brainstorm Usage entry; `sprint-master` is internal to `team-plan` and stays out of the chain.
- Rewrite the description to reflect:
  - `quick-brainstorm` produces a spec (not a plan).
  - On approval, the spec is handed off to `team-plan`, which generates the plan and calls `sprint-master` internally to produce Sprint Contract files.
  - When the plan is ready, handoff to team-driven-development is offered.
  - Preserve the existing behavior note: when team-driven-development is invoked without a plan, it suggests quick-brainstorm automatically.

#### 3. `docs/README.ja.md` — 主な機能 `Quick Brainstorm` entry

Mirror change #1 in Japanese, keeping the existing tone (です・ます, English technical terms preserved as-is).

- Replace the flow chain `quick-brainstorm → team-plan → sprint-master → team-driven-development` with `quick-brainstorm → team-plan → team-driven-development`.
- Keep the surrounding description (minimal-dialogue blurb, `/quick-brainstorm` invocation, auto-suggest behavior) unchanged in substance.

#### 4. `docs/README.ja.md` — `Quick Brainstorm と併用（自己完結）`

Mirror change #2 in Japanese, matching paragraph structure and information content one-to-one.

- Change the flow chain to `/quick-brainstorm <タスクの説明> → team-plan → team-driven-development`.
- Update the description:
  - `quick-brainstorm` generates a spec (not a plan).
  - After approval, handoff to `team-plan`, which generates the plan and invokes `sprint-master` internally.
  - When the plan is ready, handoff to team-driven-development is offered.
  - Preserve the auto-suggest behavior note.

### Wording Rules

- Match the granularity of the existing Deep Brainstorm Usage entry.
- Flow notation must list only skills the user invokes manually. Skills called as internal subagents (notably `sprint-master`) are excluded from arrow chains and, where useful, mentioned in prose. Apply this consistently across the README.
- Preserve the existing English↔Japanese parallel structure (same number of bullets, same paragraph order).
- Skill names are introduced with code formatting on first use; subsequent mentions can use plain names.
- Do not modify CLAUDE.md or skill files; this is documentation-only.

### Error Handling

None — documentation edits, no commands executed.

### Testing Strategy

- **Manual review**: Re-read the Key Features and Usage Quick Brainstorm sections after the edit. Confirm they match the granularity and convention of the Deep Brainstorm Usage entry.
- **Convention check**: Grep `sprint-master` across `README.md` and `docs/README.ja.md` and verify it never appears inside an arrow chain. Remaining occurrences should be limited to: (a) the dedicated Sprint Master entry, (b) prose inside the Team Plan entry, (c) the F4 Sprints Gate description in How It Works, (d) the manual `/sprint-master` invocation example.
- **English↔Japanese parity**: Diff the two READMEs side by side at the modified locations. Section structure, bullet counts, and conveyed facts must match.
- **Sprint Contract perspective**: Static review (`static` profile) is sufficient. No runtime or browser validation needed.

## File Changes

| File | Status | Purpose |
| --- | --- | --- |
| `README.md` | Modify | Fix two Quick Brainstorm flow notations: Key Features entry (drop `sprint-master`) and Usage subsection (add `team-plan`, drop `sprint-master`); rewrite Usage description. |
| `docs/README.ja.md` | Modify | Mirror the English changes in Japanese, preserving paragraph structure. |
| `docs/team-dd/specs/2026-04-18-readme-quick-brainstorm-flow-fix-design.md` | Create | This spec. |
| `docs/team-dd/plans/2026-04-18-readme-quick-brainstorm-flow-fix.md` | Create (by team-plan) | Implementation plan. |
| `sprints/2026-04-18-readme-quick-brainstorm-flow-fix/` | Create (by sprint-master) | Sprint Contract files, when executed. |
| Other Key Features entries, Deep Brainstorm Usage, How It Works, other Usage subsections, skill files, `CLAUDE.md`, marketplace.json | Not modified | Out of scope. |
