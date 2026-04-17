# sprint-master Skill Design

## Overview

`sprint-master` is a new team-driven-development plugin skill that consolidates Sprint Contract generation into a single owner. It takes a spec path and a plan path as input and writes a feature-scoped directory under `sprints/<topic>/` containing `common.md` and `task-N.md` files. It is invoked synchronously by `team-plan` after plan generation, invoked by `team-driven-development` via a fail-fast gate when the sprints directory is missing, and invocable directly by humans.

## Motivation

- Sprint Contract generation is currently distributed across four sites: `deep-brainstorm` / `quick-plan` write a `## Sprint Contract` section into the spec, `team-plan` fails fast when that section is absent, and the Lead regenerates per-task contracts at runtime (Phase A-5). This violates single-responsibility and fragments evolution of the contract schema.
- In-spec Sprint Contract sections bloat specs and force downstream Worker / Reviewer dispatch to carry the full spec content instead of only the acceptance surface for the current task. A per-task file layout under `sprints/` enables precise dispatch and independent regeneration.
- `team-plan` Decision 3 (Y fail-fast) explicitly marked itself as a placeholder pending `sprint-master`. This spec completes that commitment.
- Project policy accepted during Phase 1: additional tokens are acceptable if they improve development success rate and reduce drift between spec intent and downstream consumers. This policy licenses self-contained sprints files without aggressive token minimization.

## Design

### Skill Identity

- **Name:** `sprint-master`
- **Path:** `skills/sprint-master/SKILL.md`
- **Invocation:** `/team-driven-development:sprint-master <spec-path> <plan-path>`
- **Positioning:** Single owner of Sprint Contract generation inside the plugin. No other skill or Lead phase generates contract content after this spec lands.
- **Invokers (all first-class):** `team-plan` (synchronous, after plan file is written), `team-driven-development` (synchronous via F4 gate on missing sprints), and humans (direct invocation, typically to regenerate contracts after a plan edit).

### Input

- Two positional path arguments, both required:
  - `<spec-path>`: absolute or repo-relative path to a spec markdown file.
  - `<plan-path>`: absolute or repo-relative path to a plan markdown file.
- Both files must exist and be readable.
- The plan must contain at least one `### Task N:` heading; otherwise the skill stops with an error (no partial writes).

### Output Layout

- `sprints/<topic>/common.md` — feature-level shared fields.
- `sprints/<topic>/task-N.md` — task-specific fields, one file per task in the plan.
- `<topic>` is derived from the plan filename by stripping the trailing `.md`. Example: `docs/team-dd/plans/2026-04-18-sprint-master.md` → `sprints/2026-04-18-sprint-master/`.
- The `sprints/` directory is tracked in git (included in commits, not ignored).

### common.md Schema

```markdown
# Sprint Contract: <feature>

## Spec
<relative path to spec, from repo root>

## Plan
<relative path to plan, from repo root>

## Shared Criteria
- <cross-task rule>
- <cross-task rule>

## Domain Guidelines
- <domain>: guidelines/<domain>.md
```

- `Spec` and `Plan` are machine-derived from the input arguments.
- `Shared Criteria` captures rules that apply to every task in the feature (e.g., "all new code has tests", "no secrets in logs"). Derived by `sprint-master` from the spec's Design and Testing Strategy sections.
- `Domain Guidelines` lists the applicable `guidelines/<domain>.md` files detected from the file-path patterns in the plan, following the existing `team-driven-development` Phase 0 domain detection table.

### task-N.md Schema

```markdown
# Sprint Contract: Task N - <name>

## Reviewer Profile: static | runtime | browser

## Effort Score: N → Model: haiku | sonnet | opus

## Success Criteria
- [ ] <specific, verifiable condition>
- [ ] Tests pass: `<exact test command>`

## Non-Goals
- <what this task does NOT do>

## Runtime Validation (if runtime/browser)
- `<exact test command>`

## Browser Validation (if browser)
- [ ] <UI flow to verify>
```

- All fields are per-task and additive to `common.md`. `task-N.md` never overrides fields declared in `common.md`; the two files occupy disjoint field sets (D-strict model).
- `Reviewer Profile` is chosen by applying the current `team-driven-development` Phase A-4 ruleset (files characteristics → profile) verbatim.
- `Effort Score` is computed by applying the current Phase A-3 ruleset (five factors, each contributing +1) verbatim, with the existing score → model mapping (0-1 → haiku, 2 → sonnet, 3+ → opus).
- `Success Criteria` is derived from the plan task description plus the spec, and must incorporate all applicable Domain Guidelines content (Reviewers do not receive Guidelines separately).
- `Non-Goals` requires at least one entry.
- `Runtime Validation` is present when `Reviewer Profile` is `runtime` or `browser`.
- `Browser Validation` is present only when `Reviewer Profile` is `browser`.

### Generation Flow

1. Read the spec at `<spec-path>`. Fail fast if missing or unreadable.
2. Read the plan at `<plan-path>`. Fail fast if missing or unreadable.
3. Parse the plan: extract all `### Task N:` sections with task names, file paths, and test commands. Fail fast if zero tasks are found.
4. Derive `<topic>` from the plan filename and compute the target directory `sprints/<topic>/`.
5. For each task in the plan:
   - Apply A-3 ruleset → Effort Score and Model.
   - Apply A-4 ruleset → Reviewer Profile.
   - Derive Success Criteria from the plan task description plus relevant spec sections, incorporating applicable Domain Guidelines.
   - Derive at least one Non-Goal.
   - If Profile is `runtime` or `browser`, derive Validation commands from the plan's test commands.
6. Derive `common.md` content from the spec's Design and Testing Strategy sections plus detected Domain Guidelines.
7. Run Contract QA self-review (see below). On findings, fix in place and re-run. Maximum two rounds.
8. Write `common.md` and all `task-N.md` files in parallel to `sprints/<topic>/`.
9. Return success with the target directory path.

### Contract QA Self-Review

Replaces the current Phase A-5.5 Contract QA. Mechanical pass before writing files:

1. **Criterion specificity** — each `Success Criteria` item is specific and verifiable. Reject phrasings such as "Code works"; require concrete conditions (e.g., "GET /api/users returns 200 with JSON array").
2. **Test command completeness** — each test command includes a file path or filter, not a bare runner name.
3. **Non-Goal presence** — every `task-N.md` declares at least one `Non-Goal`.
4. **Profile alignment** — `Reviewer Profile` matches the task's file characteristics (e.g., tasks touching `.tsx` cannot be `static`).
5. **Secret scan** — detect patterns `AKIA[0-9A-Z]{16}`, `Bearer `, `password=`, `api[_-]?key=`. Redact matches with `<REDACTED>` and emit a warning line at the top of `common.md`.
6. **Path traversal guard** — all write targets must resolve to `sprints/<topic>/` within the repo root. Reject absolute paths, `..` segments, and any path escaping the target directory.

Fix findings in place. Maximum two retry rounds. Surface findings verbatim to the invoking caller on the third failure.

### Upstream Skill Changes

This spec includes upstream modifications required to make the new layout coherent.

- **`skills/deep-brainstorm/SKILL.md`** — remove the guidance that has specs carry a `## Sprint Contract` section. The Extended Spec Format section no longer lists Sprint Contract as a spec-owned heading.
- **`skills/quick-plan/SKILL.md`** — remove `## Sprint Contract` from the spec template. Update the self-review checklist to drop the Sprint Contract presence check.
- **`skills/team-plan/SKILL.md`**:
  - Remove the check that fails fast on spec missing `## Sprint Contract`.
  - After writing the plan file, invoke `sprint-master` via the `Skill` tool with the spec and plan paths.
  - Add a `**Sprints:** sprints/<topic>/` line to the plan header immediately below the existing `**Spec:**` line, derived by the same topic-derivation rule.
  - On `sprint-master` failure, surface the error plus the re-run command (`/team-driven-development:sprint-master <spec> <plan>`) to the user.
- **`skills/team-driven-development/SKILL.md`**:
  - Delete Phases A-3 (Effort Scoring), A-4 (Reviewer Profile), A-5 (Sprint Contract Generation), and A-5.5 (Contract QA). Their responsibilities move to `sprint-master`.
  - After Phase A-0 and before Phase A-1, check that the plan's referenced `sprints/<topic>/` exists. If missing, enter F4 gate: present `"sprints/ not found. Run sprint-master now? [yes/no]"`. On yes, invoke `sprint-master` with the detected spec and plan paths, then proceed. On no, abort with instructions.
  - In Phase B-2 (Dispatch Worker), read `sprints/<topic>/common.md` and `sprints/<topic>/task-N.md`, embed their combined content in the Worker prompt alongside the existing codebase context.
  - In Phase B-4 (Review), dispatch Reviewer with the same combined contract content.
- **`skills/solo-review/SKILL.md`** — documentation-only change: note that `--contract <path>` can point at `sprints/<topic>/task-N.md` and that Level 1 detection prefers this location.
- **`templates/sprint-contract-template.md`** — delete. Schema lives inside `skills/sprint-master/SKILL.md` and is not duplicated.
- **`guidelines/writing.md`** — add a subsection describing the `sprints/` layout (directory per feature, `common.md` + `task-N.md`) and the field-partition rule between the two files.

### Error Handling

- **Spec or plan missing/unreadable**: stop. Emit `Spec file not found: <path>` or `Plan file not found: <path>`. No partial writes.
- **Plan has zero tasks**: stop. Emit `No tasks found in plan: <path>`. No partial writes.
- **Path traversal in derived target**: stop. Emit `Invalid target path: <path>`. No writes.
- **Secrets detected**: redact in the output files, add a warning line at the top of `common.md`, continue. Do not modify the spec or plan.
- **Self-review fails after two retry rounds**: surface findings verbatim to the caller. Do not write files.
- **Partial write due to unexpected error**: `sprints/<topic>/` may contain some files but not all. User re-runs `sprint-master` (idempotent; overwrites deterministically).

### Testing Strategy

Markdown-only skill — testing is manual and comparative.

- **Smoke test** — minimal fixture: spec with two task-referenced requirements + plan with two tasks. Verify `sprints/<topic>/common.md`, `task-1.md`, `task-2.md` are generated with all schema fields populated.
- **Fail-fast tests**:
  - Missing spec path → verify stop with the spec-not-found message, no writes.
  - Missing plan path → verify stop with the plan-not-found message, no writes.
  - Plan with no task sections → verify stop with the no-tasks message, no writes.
  - Plan path containing `..` → verify path traversal rejection, no writes.
- **Heuristic faithfulness test** — fixture plan that exercises every A-3 scoring factor (files ≥ 4, core/shared/security/auth dir, each keyword class, cross-cutting, new subsystem) and every A-4 profile trigger (static/runtime/browser). Verify generated `Effort Score` and `Reviewer Profile` match the current team-driven-development ruleset exactly. This is the R3 mitigation.
- **Self-review test** — fixture with a vague Success Criterion ("Code works"), a task missing Non-Goals, and an `AKIA...` string in a test command. Verify the self-review rewrites the criterion, adds a Non-Goal placeholder or stops for user input, redacts the secret, and emits the warning.
- **Integration test** — run `deep-brainstorm` → `team-plan` → `sprint-master` end-to-end on a small fixture. Confirm `team-driven-development` can execute the resulting plan without any manual contract authoring step.
- **Idempotency test** — run `sprint-master` twice in a row on identical inputs. Verify the second run produces byte-identical outputs.

## File Changes

| File | Status | Purpose |
| --- | --- | --- |
| `skills/sprint-master/SKILL.md` | Create | The new skill definition, including the contract schemas and generation rules |
| `skills/team-plan/SKILL.md` | Modify | Drop spec Sprint Contract validation; call `sprint-master` synchronously; add `**Sprints:**` header line |
| `skills/team-driven-development/SKILL.md` | Modify | Delete Phases A-3/A-4/A-5/A-5.5; add sprints directory check and F4 gate; read sprints files in Phase B-2/B-4 |
| `skills/deep-brainstorm/SKILL.md` | Modify | Remove Sprint Contract section guidance from Extended Spec Format |
| `skills/quick-plan/SKILL.md` | Modify | Remove `## Sprint Contract` from spec template and self-review check |
| `skills/solo-review/SKILL.md` | Modify | Document that `--contract` supports `sprints/<topic>/task-N.md` and that Level 1 detection prefers it |
| `templates/sprint-contract-template.md` | Delete | Schema moves into `sprint-master` SKILL.md |
| `guidelines/writing.md` | Modify | Add a sprints layout subsection |
| `docs/team-dd/specs/2026-04-18-sprint-master-design.md` | Create | This design document |
| `docs/team-dd/plans/2026-04-18-sprint-master.md` | Create (follow-up) | Implementation plan, produced by `team-plan` after this spec is approved |

---

## Decision Log

### Decision 1: Sprint Contract storage layout

- **Alternatives considered:**
  - A. Single file per feature (`sprints/<topic>.md` with common + all tasks concatenated)
  - B. Directory per feature plus file per task (`sprints/<topic>/common.md` + `task-N.md`)
  - C. Common inline in plan header; only task details under `sprints/<topic>/task-N.md`
  - D. Single file per feature with heading-anchor sub-structure
- **Chosen:** B.
- **Reasoning:** B gives per-task dispatch granularity — Reviewer and Worker prompts can carry exactly the contract for the current task plus the feature-scoped common, matching the plugin's hybrid-density principle. A and D require the caller to parse or section-slice the file before dispatch, which reintroduces work the skill should own. C leaves Common inside the plan, which couples plan size to contract volume and defeats the "details live in sprints" intent.

### Decision 2: Invocation timing relative to plan generation

- **Alternatives considered:**
  - T1. Spec-approval step of `deep-brainstorm` / `quick-plan`
  - T2. During plan generation (synchronous call from `team-plan`)
  - T3. At execution start (`team-driven-development` Phase A replacement)
  - T4. Both T2 and T3 (dual ownership)
- **Chosen:** T2.
- **Reasoning:** T2 binds contract generation to the moment task decomposition is authoritative — `team-plan` has just decided the task list and file layout. T1 forces `sprint-master` to redo task decomposition, reintroducing drift. T3 is wasteful because the plan already carries the exact test commands and files, so fresh codebase reads buy nothing. T4 creates shared ownership without an observable benefit.

### Decision 3: Behavior when sprints directory is missing at execution time

- **Alternatives considered:**
  - F1. Fail-fast with Lite Mode suggestion
  - F2. Keep Lead A-5 as a runtime fallback
  - F3. Auto-dispatch `sprint-master` without user prompt
  - F4. Fail-fast with an inline "run sprint-master now? [yes/no]" prompt
- **Chosen:** F4.
- **Reasoning:** F2 reintroduces the distributed generation that this skill is built to eliminate. F3 skips the user decision on whether an auto-generated contract is acceptable for their specific plan. F1 is clean but wastes the user's session by requiring a second invocation. F4 is the minimum-step safe path and aligns with the first-class human invocation supported by Decision 6.

### Decision 4: Scope of upstream rewrites

- **Alternatives considered:**
  - A. Include upstream rewrites (`deep-brainstorm`, `quick-plan`, `team-plan`, `team-driven-development`, `solo-review`) in this spec
  - B. `sprint-master` only; upstream changes deferred to a later spec
- **Chosen:** A.
- **Reasoning:** Partial adoption would leave specs still carrying `## Sprint Contract` sections with `team-plan` still validating them — two schemas live simultaneously. This is the same split-brain the skill is meant to remove. Landing upstream edits in the same spec keeps the cutover atomic.

### Decision 5: Success criteria scope

- **Alternatives considered:**
  - A. Minimal (Worker and Reviewer work from sprints files alone)
  - B. Thin Lead (A plus A-3/A-4/A-5 responsibilities moved out of Lead)
  - C. B plus measurement targets (token budget, QA pass rate)
  - D. Minimal plus staged Lead absorption
  - **B+.** B plus Contract QA self-review internal to `sprint-master` (without the token-budget target from C)
- **Chosen:** B+.
- **Reasoning:** B is the minimum that actually consolidates logic — without absorbing A-3/A-4, the Lead keeps the exact heuristics the new skill is supposed to own. Adding Contract QA as an internal self-review (one of the five criteria) gives `sprint-master` an explicit quality gate without reintroducing the token-budget anti-pattern observed in `team-plan` Decision B. Token targets are excluded; project policy accepts more tokens for less drift.

### Decision 6: First-class invokers

- **Alternatives considered:**
  - A. Agent-only (only `team-plan` and `team-driven-development`)
  - B. Agent plus human direct invocation
  - C. B plus `solo-review` auto-dispatch
- **Chosen:** B.
- **Reasoning:** B matches the plugin pattern (all other skills are human-invocable). Human direct invocation is the natural recovery path when `sprint-master` fails during `team-plan` (see Decision 3) and when a plan is edited manually. C overlaps with `solo-review`'s existing Level 3 fallback without added value.

### Decision 7: Abstraction form

- **Alternatives considered:**
  - Opt-1. Skill (`skills/sprint-master/SKILL.md`)
  - Opt-2. Agent (subagent definition under `agents/`)
  - Opt-3. Shared prompt library with each caller dispatching its own subagent
- **Chosen:** Opt-1.
- **Reasoning:** Skill-to-skill invocation via the `Skill` tool is the existing pattern (`team-plan`, `quick-plan`, `deep-brainstorm`). Subagent dispatch (Opt-2) does not fit `team-plan` calling inline, and human direct invocation is unnatural for agents. Opt-3 distributes generation logic across callers and defeats the single-ownership goal.

### Decision 8: Relationship between `common.md` and `task-N.md`

- **Alternatives considered:**
  - Opt-A. D-strict: additive split, disjoint field sets, no override
  - Opt-B. Static expansion: `common` content duplicated into every `task-N.md`
  - Opt-C. `team-plan`'s current delta/override model applied across files
- **Chosen:** Opt-A.
- **Reasoning:** The current contract schema naturally partitions into feature-scoped fields (Shared Criteria, Domain Guidelines, Spec/Plan refs) and task-scoped fields (Profile, Effort, Success Criteria, Non-Goals, Validation). With disjoint field sets, override semantics are not required. Opt-B is loose duplication that makes `common.md` regeneration pointless. Opt-C imports the override model, which worked inside a single plan file but adds merge complexity when split across files.

### Decision 9: Generation flow implementation

- **Alternatives considered:**
  - Flow-1. Sequential, plan-first: write plan, then invoke `sprint-master` reading the plan file
  - Flow-2. Content-passed: pass plan content via argument or temporary file
  - Flow-3. Rollback: Flow-1 plus plan deletion on `sprint-master` failure
- **Chosen:** Flow-1.
- **Reasoning:** Flow-1's invocation path is identical whether called from `team-plan` or by a human — recovery instructions match day-to-day invocation, so users need to learn one command. Flow-2 hits `Skill`-tool argument-size limits for non-trivial plans. Flow-3's rollback treats `sprint-master` failure as a reason to discard the plan, which is not the user's intent.

### Declined concerns

- **Token budget target for `task-N.md`** — declined. Project policy prefers extra tokens for reduced drift between spec intent and Worker/Reviewer consumption. This mirrors the `team-plan` Decision B rejection of file-size targets.
- **Auto-dispatch on missing sprints without user prompt (F3)** — declined. Silent auto-generation at execution time is inconsistent with the explicit user-gated sprint generation pattern elsewhere in the plugin.

---

## Unresolved Items

- [ ] **Exact transcription of current A-3 and A-4 rulesets into `sprint-master` SKILL.md** — the design references the rulesets verbatim; implementation must copy them without paraphrase. To be confirmed during implementation through the heuristic faithfulness test.
- [ ] **`guidelines/writing.md` wording** — the new subsection on sprints layout is in scope but exact wording is deferred to implementation (same style as existing subsections).
- [ ] **Backfill of `sprints/` for already-landed features** — features planned before `sprint-master` exists (e.g., the `team-plan` spec and plan already on disk) have no sprints directory. Backfilling is not in scope for this spec; it can be done by running `sprint-master` manually if desired later.

---

## Checklist Snapshot

| # | Item | Status | Notes |
| --- | --- | --- | --- |
| 1 | Purpose | confirmed | Single-owner skill for Sprint Contract generation; called by `team-plan` after plan generation (T2); files under `sprints/<topic>/`; humans may invoke directly |
| 2 | Success criteria | confirmed | B+ five items: Worker works from task-N + common alone; Reviewer decides from task-N + common + diff; Lead A-5 deleted; A-3/A-4 absorbed; Contract QA internal self-review |
| 3 | Scope boundaries | confirmed | Scope A (upstream rewrites included) plus F4 (fail-fast + auto-propose gate) plus B invokers (agent + human) plus `guidelines/writing.md` subsection |
| 4 | Users / stakeholders | confirmed | First-class invokers: `team-plan`, `team-driven-development`, humans. Downstream consumers: Lead, Worker, Reviewer, Architect, `solo-review` |
| 5 | Alternatives considered | confirmed | Decisions 1 through 9 cover all branches evaluated during Distill and Challenge |
| 6 | Assumptions | confirmed | Current contract field set preserved; plan-filename / sprints-dir naming mirror; Worker/Reviewer/Architect agent definitions unchanged; Domain Guidelines path convention unchanged; file-path I/O only |
| 7 | Major constraints | confirmed | English only (CLAUDE.md policy); markdown + shell only; Skill pattern; three reviewer profiles preserved; `sprints/` committed to git; four agent definition files untouched |
| 8 | Risks | confirmed | R1 transient inconsistency (mitigated by F4 + human re-run); R2 naming drift (mitigated by header line); R3 A-3/A-4 porting drift (high, mitigated by heuristic faithfulness test); R4 repeated QA failure (max 2 rounds); R5 team-plan breaking change (plugin minor bump + changelog); R6 git churn (accepted) |
| 9 | Security | confirmed | S1 secret passthrough (scan and redact, warning in common.md); S2 validation-command secrets (same treatment); S3 path traversal (writes constrained to `sprints/<topic>/`); semantic code security remains Reviewer responsibility |
| 10 | NFR | confirmed | N1 latency ≤ 30s for a typical 5-task plan; N2 idempotent regeneration; N3 one-shot QA pass via internal self-review; N4 SKILL.md length ≤ 1.5× `team-plan` SKILL.md; N5 file size an advisory target, not an upper bound |
