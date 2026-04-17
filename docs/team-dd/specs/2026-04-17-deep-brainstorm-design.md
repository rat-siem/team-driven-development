# deep-brainstorm Skill Design

## Overview

`deep-brainstorm` is a rigorous, assertive variant of the brainstorming skill. It replaces brainstorming for vague or high-stakes requirements by combining deep-dive restatement, strong counter-proposals, a gated 10-item checklist with dynamic additions, and external subagent review. It produces an extended spec with a decision log and an unresolved-items section, then hands off to `writing-plans`.

## Motivation

- Existing brainstorming asks one question at a time but rarely pushes back or challenges user assumptions hard enough to surface hidden premises.
- Vague requirements often ship with embedded assumptions that bite later in Worker or Reviewer stages, causing rework.
- Self-review is structurally weak: the mind that wrote the spec cannot reliably catch its own blind spots. The plugin already uses Lead/Worker/Reviewer separation elsewhere; the design-phase review should follow the same philosophy.
- Users need a single high-rigor skill for serious design work, where vague input must be distilled, challenged, and hardened before any implementation plan is written.

## Design

### Skill Layout

- **Primary**: `skills/deep-brainstorm/SKILL.md` — main skill definition.
- **Subagent reviewer prompt**: `skills/deep-brainstorm/prompts/reviewer.md` — loaded and passed to the review subagent.
- **Language**: English (per plugin's CLAUDE.md policy).
- **Registration**: auto-discovered from `skills/` directory (no changes to `plugin.json` needed).

### Invocation and Positioning

- Entry point: user types `/deep-brainstorm`.
- Relationship to existing `brainstorming`: **replacement for vague or high-stakes requirements**. Not a layer on top of brainstorming; users choose which skill to invoke based on the rigor they want.
- Terminal state: after spec approval, invokes `writing-plans` skill (same as brainstorming).
- Self-contained: does not depend on or invoke superpowers skills beyond `writing-plans` at handoff.

### Three Phases

Phase progression is gated: a phase ends only when all its checklist items are `confirmed` or `N/A`. Users can explicitly mark items `N/A` to skip.

#### Phase 1 — Distill

Establish purpose, success criteria, scope boundaries, and stakeholders.

- Turn format: **structured three-part** (strict).
  ```
  📌 Understanding: [one- or two-sentence restatement]
  🔍 Gaps: [2-3 bullet points of ambiguity or missing context]
  ❓ Question: [one focused question, multiple-choice preferred]
  ```
- Owns checklist items: Purpose, Success criteria, Scope boundaries, Users/stakeholders.

#### Phase 2 — Challenge

Surface counter-proposals, stress-test assumptions, pin down major constraints.

- Turn format: **dynamic**, counter-proposal-centric.
- Claude presents 2-3 alternatives per major decision with explicit trade-offs and a recommended option with reasoning.
- Counter-proposals must be motivated by a real concern, not contrarianism for its own sake.
- Owns checklist items: Alternatives considered, Assumptions, Major constraints.

#### Phase 3 — Harden

Fill remaining risk, security, and non-functional concerns.

- Turn format: **dynamic**, targeted probes at unresolved items.
- May include proposal-style confirmation ("I'll proceed with X unless you object").
- Owns checklist items: Risks, Security, NFR (performance etc.).

### Checklist and Termination Gate

Fixed floor of 10 items, extendable by Surfaced Concerns (see below). Each item has one of four states: `unknown` / `draft` / `confirmed` / `N/A`.

| # | Item | Phase |
|---|---|---|
| 1 | Purpose | Distill |
| 2 | Success criteria | Distill |
| 3 | Scope boundaries | Distill |
| 4 | Users / stakeholders | Distill |
| 5 | Alternatives considered | Challenge |
| 6 | Assumptions | Challenge |
| 7 | Major constraints | Challenge |
| 8 | Risks | Harden |
| 9 | Security | Harden |
| 10 | NFR (performance, reliability, etc.) | Harden |

**Phase gate**: all items in that phase must be `confirmed` or `N/A` before advancing.

**Final gate**: after all items are resolved and the design is presented, wait for **explicit user approval** before writing the spec file. This is the authoritative termination.

**Confidence signal (internal only)**: Claude self-rates per-item confidence each turn and uses the lowest-confidence item to prioritize the next question. Confidence is **never a gate** — only a prioritization tool. This avoids the known miscalibration of LLM self-confidence.

**Phase status line**: each turn starts with a one-line status.
```
[Phase 2 Challenge | Unresolved: 5, 6 | Added: migration]
```

### Surfaced Concerns (Dynamic Checklist Additions)

The 10-item list is a floor, not a ceiling. When Claude detects a concern that must be resolved before design can be written, it proposes adding it:

> ⚠ **Surfaced concern: [title]** — [why it matters]. Add to checklist? (**Add / Decline / Defer**)

Outcomes:

- **Add**: becomes item #11+, tracked like any other item, must reach `confirmed` before the owning phase closes.
- **Decline**: recorded in the spec's Decision Log under "Declined concerns" with the user's reasoning.
- **Defer**: recorded in the spec's Unresolved Items section — must be addressed before implementation starts.

No surfaced concern is ever silently dropped. This mechanism makes Claude co-responsible for coverage and prevents the 10-item checklist from becoming pro-forma.

### Anti-Patterns (Explicit in SKILL.md)

1. **Checklist theater** — asking about items purely to tick boxes. Questions must serve real clarification.
2. **Contrarianism** — counter-proposals without motivation. Every alternative must have an explicit reason it may be better than the current direction.
3. **Scope creep via surfacing** — surfacing every possible concern. Only surface items that genuinely block design (not implementation details).
4. **Question bombing** — more than one question per turn. Always one focused question.
5. **Premature design** — presenting a design before all checklist items are resolved. Hard-gated.

### Extended Spec Format

Saved to `docs/team-dd/specs/YYYY-MM-DD-<topic>-design.md` (matches plugin convention).

```markdown
# [Feature Name] Design

## Overview
## Motivation
## Design
  ### [component/section]
  ### Error Handling
  ### Testing Strategy
## File Changes

---

## Decision Log
### Decision N: [topic]
- **Alternatives considered**: [A / B / C]
- **Chosen**: [option]
- **Reasoning**: [why, including why others were rejected]
- **Declined concerns**: [surfaced concerns the user dismissed, with reasons]

## Unresolved Items
- [ ] [deferred concern] — must be resolved before implementation

## Checklist Snapshot
| # | Item | Status |
|---|---|---|
| 1 | Purpose | confirmed |
| ... | ... | ... |
```

The Decision Log and Checklist Snapshot give downstream Workers and Reviewers a clear audit trail for design choices — preserving the reasoning generated during deep-dive and challenge phases.

### Review Pipeline

Replaces the pure self-review used by brainstorming and quick-plan.

1. **Lightweight self-review** — mechanical pass only: placeholder scan (`TBD`, `TODO`), obvious internal contradictions, missing sections. Target ~30 seconds.
2. **Subagent review** — dispatch a fresh subagent (no conversation context) with:
   - The spec file path.
   - The reviewer prompt from `skills/deep-brainstorm/prompts/reviewer.md`.
   - Explicit criteria: 10-item coverage, Decision Log reasoning soundness, Unresolved Items legitimacy, internal consistency, ambiguity.
   - Output format: `PASS` or `CHANGES_REQUESTED: [specific findings]`.
3. **Revision loop** — if `CHANGES_REQUESTED`, revise the spec inline and re-dispatch. **Maximum 2 revision rounds**; after that, surface findings to the user and let them decide whether to continue.
4. **User approval** — ask the user to review the spec file and approve before proceeding.

### Error Handling and Edge Cases

- **User dismisses all counter-proposals**: log each as a declined concern in the Decision Log. Do not loop. Proceed with the original direction.
- **User defers a decision** ("either is fine", "up to you"): mirror `quick-plan` convention — choose the most comprehensive option, record as a Deferred decision, proceed.
- **Subagent review fails twice**: surface findings to the user verbatim. User decides whether to continue or revise further manually.
- **User tries to skip ahead** ("just write the spec"): Claude acknowledges, marks remaining unresolved items as `Deferred` in Unresolved Items, and proceeds to design. Ultimate control stays with the user.

### Testing Strategy

- **Manual validation**: run `/deep-brainstorm` against a deliberately vague prompt (e.g., "I want to add notifications"); verify the three phases execute, checklist items progress, subagent review triggers, spec includes Decision Log and Checklist Snapshot.
- **Comparative validation**: run the same vague prompt through `brainstorming` and `deep-brainstorm`; diff the resulting specs. `deep-brainstorm` should show more completeness, explicit alternatives, and traceable reasoning.
- **Regression check**: confirm handoff to `writing-plans` still works (same terminal state as `brainstorming`).

### Integration with Existing Plugin Skills

- **Replaces**: `brainstorming` for vague or high-stakes cases (user chooses per invocation).
- **Coexists with**: `quick-plan` (light-touch, requirements mostly clear) — users pick based on ambiguity level.
- **Hands off to**: `writing-plans` after spec approval — identical terminal transition to `brainstorming`.
- **Downstream consumers**: plans produced from deep-brainstorm specs are executed by `team-driven-development` as usual; Workers and Reviewers benefit from the Decision Log.

## File Changes

| File | Status | Purpose |
|---|---|---|
| `skills/deep-brainstorm/SKILL.md` | Create | Main skill definition with phases, checklist, turn formats, anti-patterns, review pipeline. |
| `skills/deep-brainstorm/prompts/reviewer.md` | Create | Prompt loaded by the review subagent — criteria and output format. |
| `docs/team-dd/specs/2026-04-17-deep-brainstorm-design.md` | Create | This spec. |

No changes to `plugin.json` (skills are auto-discovered) or other existing skills.

---

## Decision Log

### Decision 1: Skill name
- **Alternatives considered**: `deep-plan`, `deep-brainstorm`, `spec-forge`, `socratic-design`.
- **Chosen**: `deep-brainstorm`.
- **Reasoning**: fits the plugin ecosystem where users already know `brainstorming` and `quick-plan`; "deep" signals "rigorous variant" clearly; avoided `deep-plan` because it collides with `writing-plans` (plans are an execution artifact, not a design artifact); `spec-forge` is vivid but requires onboarding.
- **Declined concerns**: none.

### Decision 2: Relationship to `brainstorming`
- **Alternatives considered**: (A) replace, (B) parallel selection, (C) pre-stage, (D) post-stage.
- **Chosen**: (A) replacement for vague or high-stakes requirements.
- **Reasoning**: user wants a single high-rigor go-to skill. Parallel options create decision fatigue; pre/post staging adds coordination without clear benefit.

### Decision 3: Termination gate
- **Alternatives considered**: (A) user-driven, (B) checklist-only, (C) confidence-only, (D) B + A, (E) B + C.
- **Chosen**: checklist as backbone + user approval as final gate + confidence as internal prioritization only.
- **Reasoning**: LLM self-confidence is known to be miscalibrated, so confidence-as-gate risks overconfident early termination. Checklist ensures coverage; user approval keeps human authority; confidence remains useful to pick what to probe next.
- **Declined concerns**: pure (D) without confidence signal — would lose the prioritization value.

### Decision 4: Turn format
- **Alternatives considered**: (A) always structured three-part, (B) always dynamic, (C) hybrid (structured early, dynamic late).
- **Chosen**: (C) hybrid — structured three-part in Phase 1, dynamic in Phases 2-3.
- **Reasoning**: rigor pays off most while establishing purpose and scope; once aligned, dynamic flow keeps tempo and avoids performative structure.

### Decision 5: Spec output format
- **Alternatives considered**: (A) same as brainstorming, (B) extended with Decision Log and Unresolved Items, (C) two-stage (requirements doc then design doc).
- **Chosen**: (B) extended.
- **Reasoning**: the decision-making effort expended during Challenge phase should not be thrown away — preserving it in the spec gives Workers and Reviewers an audit trail and differentiates the output meaningfully from `brainstorming`. Two-stage was rejected as over-engineered for a single-feature design.

### Decision 6: Dynamic checklist extensions
- **Alternatives considered**: fixed 10 only; Claude may freely add items; hybrid with user approval.
- **Chosen**: hybrid with user approval (Surfaced Concerns).
- **Reasoning**: fixed-only risks checklist theater and misses real concerns; free additions risk scope creep. User gatekeeping balances rigor and focus; routing to Add/Decline/Defer ensures no concern is silently dropped.

### Decision 7: Spec review mechanism
- **Alternatives considered**: (A) self-review only, (B) subagent review only, (C) hybrid (light self-review + subagent review).
- **Chosen**: (C) hybrid.
- **Reasoning**: self-review is structurally weak for the same-mind reason; subagent review gives genuinely fresh eyes, which is consistent with the plugin's Lead/Worker/Reviewer philosophy. Light self-review catches mechanical issues cheaply before the subagent round. Two-retry cap prevents infinite review loops.
- **Declined concerns**: "too heavyweight" — rejected because the specs produced by this skill are precisely the cases where external review pays off.

## Unresolved Items

- [ ] Exact wording of the Phase 1 restatement template — to be drafted during implementation.
- [ ] Exact structure and criteria detail of `prompts/reviewer.md` — to be drafted during implementation.
- [ ] Whether to also create `templates/spec-template.md` or inline the template in SKILL.md — to be decided during implementation based on template size.

## Checklist Snapshot

| # | Item | Status | Notes |
|---|---|---|---|
| 1 | Purpose | confirmed | Rigorous variant of brainstorming for vague requirements. |
| 2 | Success criteria | confirmed | Extended spec with Decision Log + Unresolved Items; replaces brainstorming for target cases. |
| 3 | Scope boundaries | confirmed | Lives in team-driven-development plugin; no standalone install. |
| 4 | Users / stakeholders | confirmed | Plugin users invoking `/deep-brainstorm`; downstream Worker/Reviewer agents consume Decision Log. |
| 5 | Alternatives considered | confirmed | Documented in Decision Log (7 major decisions). |
| 6 | Assumptions | confirmed | Users know `brainstorming` concept; plugin auto-discovers skills; `writing-plans` exists as handoff. |
| 7 | Major constraints | confirmed | English-only source files; self-contained; must hand off to `writing-plans`. |
| 8 | Risks | confirmed | Checklist theater, contrarianism, scope creep, review loops — each mitigated by explicit anti-patterns and caps. |
| 9 | Security | N/A | Skill is a prompt-only artifact; no data handling or secrets. |
| 10 | NFR (performance) | confirmed | Subagent review bounded to 2 retries; added token cost is acknowledged and accepted as the price of rigor. |
