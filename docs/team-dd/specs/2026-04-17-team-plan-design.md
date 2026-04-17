# team-plan Skill Design

## Overview

`team-plan` is a team-driven-development plugin skill that writes implementation plans from specs. It replaces the use of `superpowers:writing-plans` inside the plugin by producing plans aligned with team-dd Sprint Contracts, worktree-based execution, and a "minimum instruction, maximum output" token principle that applies to every LLM consumer (Lead, Worker, Reviewer, Architect).

## Motivation

- team-dd currently depends on `superpowers:writing-plans` for plan generation from `deep-brainstorm`, and `quick-plan` generates plans inline without the same token-optimization discipline. Plan generation is scattered across at least two code paths and neither was designed for Sprint Contract integration.
- team-dd runtime agents (Lead/Worker/Reviewer/Architect) all consume the plan. Plans written by `superpowers:writing-plans` carry rationale and context that downstream agents re-read unnecessarily, inflating token consumption without improving one-shot task completion.
- `deep-brainstorm` produces specs with Decision Logs and Sprint Contract information. There is no downstream skill that makes use of this structured output; `writing-plans` treats the spec generically.
- The plugin's `CLAUDE.md` language policy favors English for tokenizer efficiency. The plan-writing step is a prime application point: all downstream LLM reads inherit that token floor.

## Design

### Skill Identity

- **Name:** `team-plan`
- **Invocation:** `/team-driven-development:team-plan <spec-path>`
- **Positioning:** Sole plan-generation skill inside the team-driven-development plugin. `deep-brainstorm` hands off to it; `quick-plan` delegates its plan-generation half to it.
- **Invocation contexts supported equally:** direct human invocation and handoff from sibling skills.

### Input

- A single argument: absolute or repo-relative path to a spec markdown file.
- The spec MUST include a top-level section titled `Sprint Contract` (case-insensitive, level-2 heading `## Sprint Contract`) containing at minimum a `Profile` field with value `static`, `runtime`, or `browser`.
- No other spec shape is required beyond what `deep-brainstorm` and `quick-plan` already produce; `team-plan` reads the spec and does not enrich it.

### Output

- A single plan file written to `docs/team-dd/plans/YYYY-MM-DD-<topic>.md`, where `<topic>` is derived from the spec filename by stripping the date prefix and `-design` suffix.
- Canonical language is English. A translation file (`docs/team-dd/plans/YYYY-MM-DD-<topic>.<lang>.md`) is written only when the user explicitly requests a translation during the confirmation step.

### Plan File Structure

The plan uses a hybrid information-density strategy (Decision 1) combined with a common-plus-delta Sprint Contract layout (Decision 2).

```markdown
# <Feature> Implementation Plan

> For agentic workers: Use team-driven-development to execute.

**Goal:** <1 sentence>
**Architecture:** <2-3 sentences>
**Tech Stack:** <key technologies>
**Spec:** <relative path to spec> (authoritative; consult for rationale/decisions)

---

## Sprint Contract (Common)

- Profile: static | runtime | browser
- Shared Criteria:
  - <criterion 1>
  - <criterion 2>

> Task-level `Sprint Contract:` sections OVERRIDE these defaults per key.

---

## File Structure

| File | Status | Responsibility |
| --- | --- | --- |
| <path> | Create / Modify | <one-line responsibility> |

---

### Task N: <name>

**Files:**
- Create: <path>
- Modify: <path>
- Test: <path>

**Spec ref:** <spec-path>#<section-heading>

**Sprint Contract:** <task-level delta, one line per overridden key; omit the section entirely when no delta>

- [ ] Step 1: Write the failing test
  ```<lang>
  <actual test code>
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `<exact command>`
  Expected: FAIL with "<specific message>"
- [ ] Step 3: Write minimal implementation
  ```<lang>
  <actual code>
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `<exact command>`
  Expected: PASS
- [ ] Step 5: Commit
  ```bash
  git add <files>
  git commit -m "<message>"
  ```
```

Inline content requirements:

- Test code, implementation code, and exact shell commands are always inlined. Workers execute from the plan alone.
- Rationale, Decision Log context, and design trade-offs are NOT inlined. The plan links to spec section headings (not line numbers) via the `Spec ref` field.
- `Spec ref` is always a heading-level anchor (for example, `docs/team-dd/specs/2026-04-17-team-plan-design.md#error-handling`). The skill rejects line-number references during self-review.

Common/delta Sprint Contract rules:

- The common block lives exactly once, directly after the plan header. It declares the profile and the criteria shared by all tasks.
- Each task may include a `Sprint Contract:` section whose entries override the common block per key. Override semantics are documented with the sentence shown above in the header block.
- Tasks with no delta omit the `Sprint Contract:` section entirely (absence means "use common as-is").

### Generation Flow

1. Read spec at the provided path. Fail fast if the file is missing or unreadable.
2. Parse the `Sprint Contract` section. If absent, fail fast with the guidance message described in Error Handling.
3. Derive `<topic>` and target path.
4. Generate plan content section by section, populating each task with concrete test + implementation + command content.
5. Run the light self-review described below; fix findings inline.
6. Write the file; report the path to the caller.

### Self-Review

Before returning, the skill runs an inline mechanical pass:

- **Placeholder scan:** reject `TBD`, `TODO`, `fill in later`, `implement later`, "handle edge cases appropriately", or any bullet that lacks concrete code/command content in a Step that requires it. Fix inline.
- **Spec coverage:** every spec requirement maps to at least one task. Missing coverage requires adding tasks before writing the file.
- **Type/identifier consistency:** function names, method signatures, and file paths used across tasks match. Mismatches are fixed inline.
- **Spec ref shape:** every `Spec ref` value is a heading anchor, not a line-range. Line-range refs are converted to heading refs or removed.
- **Contract override consistency:** task-level Sprint Contract entries do not restate the common block verbatim; they contain only deltas.
- **Secret-like patterns (S1):** scan for common secret signatures (`AKIA[0-9A-Z]{16}`, `Bearer `, `password=`, `api[_-]?key=`). Replace with `<REDACTED>` and emit a warning line at the top of the plan.

### Error Handling

- **Spec file missing / unreadable:** return error `Spec file not found: <path>`; do not create a partial plan.
- **`Sprint Contract` section missing:** return error `Sprint Contract section not found in <path>. Either (1) regenerate the spec via deep-brainstorm, (2) add a "## Sprint Contract" section manually, or (3) wait for the sprint-master follow-up skill.` Stop before writing any file.
- **`Profile` value not one of `static`/`runtime`/`browser`:** return error with the offending value and the list of allowed values. Stop before writing any file.
- **Self-review detects an unfixable contradiction** (for example, task references a function that no task defines): return error identifying the contradiction; do not write a partial plan.
- **Secrets detected in spec** (S1): redact in the generated plan and emit a warning. Do not abort; the spec is not modified.

### Testing Strategy

Testing is manual and comparative because `team-plan` is a markdown-only skill.

- **Smoke test:** invoke `team-plan` against a minimal spec that contains `## Sprint Contract` with `Profile: static` and two toy tasks. Verify the output plan contains the header, the common Sprint Contract block, a File Structure table, and task sections with populated inline code.
- **Fail-fast test:** invoke `team-plan` against a spec missing the `Sprint Contract` section. Verify the skill stops without writing a plan and emits the guidance message verbatim.
- **Comparative test:** run the same non-trivial spec through `superpowers:writing-plans` and `team-plan`. Diff the outputs on (a) file size and (b) completeness of inline code per task. `team-plan` should be smaller while retaining inline code fidelity.
- **Handoff test:** run `deep-brainstorm` end-to-end, confirm the handoff target is `team-plan`, and confirm that `team-driven-development` can execute the generated plan.
- **Self-review test:** inject a spec requirement with no corresponding task, and a `TODO` inside a Step. Verify self-review fixes both before writing.

### File Changes

| File | Status | Purpose |
| --- | --- | --- |
| `skills/team-plan/SKILL.md` | Create | The new skill definition |
| `skills/deep-brainstorm/SKILL.md` | Modify | Change the handoff target from `superpowers:writing-plans` to `team-plan` in the handoff section |
| `skills/quick-plan/SKILL.md` | Modify | Replace inline plan-generation checklist steps with a handoff to `team-plan` after spec approval; leave spec-generation steps untouched |
| `docs/team-dd/specs/2026-04-17-team-plan-design.md` | Create | This design document |
| `docs/team-dd/plans/2026-04-17-team-plan.md` | Create (follow-up) | Implementation plan, produced after this spec is approved. `team-plan` does not yet exist to bootstrap its own plan; the bootstrap plan writer is chosen at approval time and is not constrained by this spec |
| `.claude-plugin/plugin.json` | Inspect, modify only if required | Determine whether the plugin auto-discovers skills in `skills/`. Modify only if explicit registration is required for the new skill |

---

## Decision Log

### Decision 1: Plan information-density strategy

- **Alternatives considered:**
  - A. Fully self-contained plan (all rationale inlined like `superpowers:writing-plans`)
  - B. Fully referenced plan (task content is all heading refs; Worker fetches everything from spec)
  - C. Hybrid: inline execution artifacts (tests, code, commands); reference rationale
- **Chosen:** C.
- **Reasoning:** Success criterion A (Worker completes each task in one shot) requires the tests, code, and commands to be at hand at execution time. Rationale is not consulted during execution and, if inlined, duplicates spec content and inflates every downstream read. B collapses criterion A because Worker context-switches between plan and spec per step. A fails the token-minimization principle because every Worker/Reviewer re-read pays the rationale cost.

### Decision 2: Sprint Contract embedding

- **Alternatives considered:**
  - A. Inline per task (full contract repeated in every task)
  - B. Common block at the top plus per-task deltas
  - C. Keep current behavior (Lead builds the contract dynamically at assignment time)
- **Chosen:** B.
- **Reasoning:** Success criterion C (Reviewer decides without guessing) requires the contract to live in the plan itself, ruling out C. A is redundant for the common case where every task shares the same profile. B satisfies criterion C while preserving DRY, and the override rule is a single documented sentence.

### Decision 3: Behavior when the spec lacks a Sprint Contract

- **Alternatives considered:**
  - X. Infer and generate the contract in `team-plan` itself
  - Y. Fail fast with guidance
  - Z-lite. Fall back to a minimal default contract
  - Z-full. Full inference from spec body and codebase
- **Chosen:** Y.
- **Reasoning:** A `sprint-master` agent is confirmed as the next-session follow-up. Z-lite becomes interim code that is discarded as soon as `sprint-master` lands. Z-full violates the minimum-instruction principle by embedding heavy inference in a skill whose responsibility is plan composition. X duplicates logic that `sprint-master` will own. Y is the only option that avoids interim code or drift while the follow-up is pending.

### Decision 4: Skill name

- **Alternatives considered:**
  - `lean-plan`, `tight-plan`, `compact-plan` (token-value-coded adjectives)
  - `write-plan`, `draft-plan`, `generate-plan` (action verbs)
  - `plan` (single noun)
  - `team-plan` (plugin-scoped noun)
- **Chosen:** `team-plan`.
- **Reasoning:** Adjectival candidates (`lean`/`tight`/`compact`) failed one of two tests: either the word is ambiguous as verb (`compact`) or the connection to the skill's function is not self-evident. Action verbs collide conceptually with `superpowers:writing-plans` and do not match the plugin's existing `deep-brainstorm`/`quick-plan` noun-phrase naming. `plan` alone is too generic and would conflict with `quick-plan` pending its rename. `team-plan` encodes plugin scope in the name, follows the noun-phrase pattern, has no verb reading, and is unambiguously the team-dd plan skill.

### Declined concerns

- **Hard file-size threshold for generated plans.** Success criterion B (smaller plan file than `superpowers:writing-plans`) was dropped during Phase 1 distillation. File size is a byproduct of C + B, not an independent target; a hard threshold would encourage deletions that damage criterion A.

---

## Unresolved Items

- [ ] `sprint-master` agent — planned for the session immediately following this one. Until it lands, `team-plan` emits the fail-fast guidance described in Error Handling when a spec lacks a Sprint Contract. Implementation of `team-plan` must not assume `sprint-master` is available.
- [ ] `quick-plan` rename to `quick-brainstorm` — deferred to a separate session. The functional change (quick-plan delegating plan generation to `team-plan`) is in scope for this spec's implementation; the rename itself is not.
- [ ] `.claude-plugin/plugin.json` skill registration requirement — to be resolved during implementation by inspecting the current plugin manifest. If auto-discovery is in effect, no change is required; otherwise, add the new skill entry.

---

## Checklist Snapshot

| # | Item | Status | Notes |
| --- | --- | --- | --- |
| 1 | Purpose | confirmed | team-dd plan writer; minimum LLM tokens × maximum downstream performance |
| 2 | Success criteria | confirmed | A (Worker one-shot), C (Reviewer unambiguous decision), D (E2E implementation success ≥ `writing-plans`); B (file size) explicitly declined |
| 3 | Scope boundaries | confirmed | Unify plan generation in team-dd via replacement; handoff from `deep-brainstorm` and delegation from `quick-plan` |
| 4 | Users / stakeholders | confirmed | Humans invoking directly and sibling skills handing off are both first-class |
| 5 | Alternatives considered | confirmed | Decisions 1–4 capture the alternatives and rejection reasons |
| 6 | Assumptions | confirmed | `sprint-master` is a confirmed follow-up; team-dd Sprint Contract schema is reused; spec carries the Sprint Contract section; output is written under `docs/team-dd/plans/`; direct-invocation caller supplies the spec path |
| 7 | Major constraints | confirmed | English-only generation; no dependency on `superpowers` skills; Sprint Contract schema conformance; Y fail-fast behavior; C hybrid plus B common+delta plan structure; translation files created only on explicit request |
| 8 | Risks | confirmed | R1 spec-ref brittleness (heading refs only), R2 over-optimization (self-review guardrail), R3 fail-fast UX (moot once `sprint-master` ships before release), R4 override inconsistency (explicit override sentence + self-review), R5 Lead plan-reading cost (thin plan, refs externalize bulk) |
| 9 | Security | confirmed | S1 spec secret passthrough — redact and warn during self-review; S2 commands and S3 external links are out of scope |
| 10 | NFR | confirmed | N1 latency ≈ `writing-plans`; N2 file size 20–40% smaller as secondary indicator; N3 one-shot rate tracked via self-review heuristic; N4 Reviewer decision lookup is plan-internal; N5 skill prompt ≤ 60–80% of `quick-plan`'s length |
| + | `sprint-master` abstraction | deferred | Recorded as an Unresolved Item; next-session scope |
