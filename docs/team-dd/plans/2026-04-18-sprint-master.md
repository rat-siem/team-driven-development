# sprint-master Implementation Plan

> **For agentic workers:** Use team-driven-development to execute this plan.

**Goal:** Consolidate Sprint Contract generation into a single-owner `sprint-master` skill that emits `sprints/<topic>/common.md` + `task-N.md` files, and rewire upstream skills accordingly.
**Architecture:** New skill under `skills/sprint-master/`. Invoked synchronously by `team-plan` after plan generation and by `team-driven-development` via F4 gate when the sprints directory is missing. Fields split D-strict between feature-scoped `common.md` and task-scoped `task-N.md`. Upstream skills (`deep-brainstorm`, `quick-plan`, `team-plan`, `team-driven-development`, `solo-review`) and `templates/`, `guidelines/writing.md` are updated atomically.
**Tech Stack:** Markdown + bash. No Node.js/Go dependencies.
**Spec:** docs/team-dd/specs/2026-04-18-sprint-master-design.md (authoritative; consult for rationale/decisions)

---

## Sprint Contract (Common)

- Profile: static
- Shared Criteria:
  - All new and modified files follow the English-only policy in `CLAUDE.md`.
  - A-3 and A-4 rulesets are transcribed into `sprint-master` without paraphrase (R3 mitigation).
  - Every task respects `guidelines/writing.md` tone and structure rules.

> Task-level `Sprint Contract:` sections OVERRIDE these defaults per key.

---

## File Structure

| File | Status | Responsibility |
| --- | --- | --- |
| `skills/sprint-master/fixtures/valid-spec.md` | Create | Minimal spec fixture used by downstream smoke tests |
| `skills/sprint-master/fixtures/valid-plan.md` | Create | Minimal plan fixture paired with valid-spec |
| `skills/sprint-master/fixtures/zero-task-plan.md` | Create | Fail-fast fixture: plan with no `### Task` sections |
| `skills/sprint-master/SKILL.md` | Create | The sprint-master skill definition |
| `templates/sprint-contract-template.md` | Delete | Schema moves into `sprint-master` SKILL.md |
| `guidelines/writing.md` | Modify | Add a `sprints/` layout subsection |
| `skills/deep-brainstorm/SKILL.md` | Modify | Remove Sprint Contract spec section guidance |
| `skills/quick-plan/SKILL.md` | Modify | Remove Sprint Contract from spec template and self-review |
| `skills/solo-review/SKILL.md` | Modify | Document sprints path in `--contract` |
| `skills/team-plan/SKILL.md` | Modify | Drop spec Sprint Contract validation; call sprint-master; add `**Sprints:**` header line |
| `skills/team-driven-development/SKILL.md` | Modify | Delete Phases A-3/A-4/A-5/A-5.5; add F4 gate; read sprints files in B-2/B-4 |

---

### Task 1: Add smoke and fail-fast fixtures

**Files:**
- Create: `skills/sprint-master/fixtures/valid-spec.md`
- Create: `skills/sprint-master/fixtures/valid-plan.md`
- Create: `skills/sprint-master/fixtures/zero-task-plan.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#testing-strategy

- [ ] Step 1: Write the failing test
  ```bash
  test ! -e skills/sprint-master/fixtures/valid-spec.md && echo PASS_PRE || echo FAIL_PRE
  test ! -e skills/sprint-master/fixtures/valid-plan.md && echo PASS_PRE || echo FAIL_PRE
  test ! -e skills/sprint-master/fixtures/zero-task-plan.md && echo PASS_PRE || echo FAIL_PRE
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `bash -c 'for f in valid-spec valid-plan zero-task-plan; do test -e skills/sprint-master/fixtures/$f.md && echo EXISTS; done'`
  Expected: FAIL with no `EXISTS` output (no files yet)
- [ ] Step 3: Write `skills/sprint-master/fixtures/valid-spec.md`
  ```markdown
  # Sample Feature Design

  ## Overview
  Toy spec used as a sprint-master smoke test input.

  ## Design

  ### Task 1: Add greeter module
  Implement a `greet(name)` function that returns "Hello, <name>".

  ### Task 2: Add greeter CLI
  Wire the greeter into a CLI entrypoint.

  ## Testing Strategy
  Unit tests for each task, exercised via the project test runner.
  ```
- [ ] Step 4: Write `skills/sprint-master/fixtures/valid-plan.md`
  ```markdown
  # Sample Feature Implementation Plan

  **Spec:** skills/sprint-master/fixtures/valid-spec.md

  ## Sprint Contract (Common)

  - Profile: static
  - Shared Criteria:
    - Tests pass.

  ### Task 1: Add greeter module

  **Files:**
  - Create: src/greeter.ts
  - Test: src/greeter.test.ts

  - [ ] Step 1: Write the failing test
    Run: `npm test -- greeter`
    Expected: FAIL

  ### Task 2: Add greeter CLI

  **Files:**
  - Create: src/cli.ts
  - Test: src/cli.test.ts

  - [ ] Step 1: Write the failing test
    Run: `npm test -- cli`
    Expected: FAIL
  ```
- [ ] Step 5: Write `skills/sprint-master/fixtures/zero-task-plan.md`
  ```markdown
  # Plan Without Tasks

  **Spec:** skills/sprint-master/fixtures/valid-spec.md

  ## Sprint Contract (Common)

  - Profile: static

  This plan intentionally contains no `### Task` sections.
  ```
- [ ] Step 6: Run test to verify it passes
  Run: `bash -c 'for f in valid-spec valid-plan zero-task-plan; do test -e skills/sprint-master/fixtures/$f.md && echo EXISTS_$f; done'`
  Expected: PASS with three lines `EXISTS_valid-spec`, `EXISTS_valid-plan`, `EXISTS_zero-task-plan`
- [ ] Step 7: Commit
  ```bash
  git add skills/sprint-master/fixtures/
  git commit -m "test(sprint-master): add smoke and fail-fast fixtures"
  ```

---

### Task 2: Scaffold sprint-master SKILL.md

**Files:**
- Create: `skills/sprint-master/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#skill-identity

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "^name: sprint-master$" skills/sprint-master/SKILL.md && echo FRONTMATTER_OK
  grep -q "HARD-GATE" skills/sprint-master/SKILL.md && echo HARDGATE_OK
  grep -q "Announce at start" skills/sprint-master/SKILL.md && echo ANNOUNCE_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `test -e skills/sprint-master/SKILL.md && echo EXISTS || echo MISSING`
  Expected: FAIL with `MISSING`
- [ ] Step 3: Write `skills/sprint-master/SKILL.md`
  ```markdown
  ---
  name: sprint-master
  description: Sole owner of Sprint Contract generation. Reads a spec and a plan and writes sprints/<topic>/common.md and task-N.md. Called by team-plan after plan generation and invocable directly.
  ---

  # Sprint Master

  Generate Sprint Contract files under `sprints/<topic>/` from a spec and a plan. Replaces the per-task in-memory contract generation in `team-driven-development` Phase A-5.

  **Announce at start:** "I'm using sprint-master to generate Sprint Contract files."

  <HARD-GATE>
  Do NOT write any file outside `sprints/<topic>/`. If the spec or plan is missing, or if the plan contains zero tasks, stop and emit the error message in Error Handling — do not create a partial sprints directory.
  </HARD-GATE>
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "^name: sprint-master$" skills/sprint-master/SKILL.md && grep -q "HARD-GATE" skills/sprint-master/SKILL.md && grep -q "Announce at start" skills/sprint-master/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/sprint-master/SKILL.md
  git commit -m "feat(sprint-master): scaffold SKILL.md with frontmatter and HARD-GATE"
  ```

---

### Task 3: Add Checklist, Process Flow, and Invocation

**Files:**
- Modify: `skills/sprint-master/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#generation-flow

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "^## Checklist$" skills/sprint-master/SKILL.md && echo CHECKLIST_OK
  grep -q "digraph sprint_master" skills/sprint-master/SKILL.md && echo DIGRAPH_OK
  grep -q "^## Invocation$" skills/sprint-master/SKILL.md && echo INVOCATION_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "^## Checklist$" skills/sprint-master/SKILL.md || echo NOT_YET`
  Expected: FAIL with `NOT_YET`
- [ ] Step 3: Append to `skills/sprint-master/SKILL.md`
  ```markdown

  ## Checklist

  1. **Read spec** — open `<spec-path>`. Fail fast if missing.
  2. **Read plan** — open `<plan-path>`. Fail fast if missing.
  3. **Parse tasks** — extract all `### Task N:` sections from the plan. Fail fast if zero found.
  4. **Derive topic** — `<topic>` = plan filename with trailing `.md` removed. Target directory = `sprints/<topic>/`. Reject path traversal.
  5. **Generate fields** — for each task, derive Reviewer Profile (A-4 ruleset), Effort Score (A-3 ruleset), Success Criteria, Non-Goals, and Validation commands. Derive Shared Criteria and Domain Guidelines for common.md.
  6. **Self-review** — run Contract QA self-review. Fix findings in place, max 2 rounds. Surface verbatim on third failure.
  7. **Write files** — write `common.md` and all `task-N.md` in parallel.
  8. **Report** — return the target directory path.

  ## Process Flow

  ```dot
  digraph sprint_master {
      "Read spec" [shape=box];
      "Read plan" [shape=box];
      "Tasks present?" [shape=diamond];
      "Emit error and stop" [shape=doublecircle];
      "Derive topic and target" [shape=box];
      "Valid target path?" [shape=diamond];
      "Generate fields" [shape=box];
      "Self-review" [shape=box];
      "QA findings?" [shape=diamond];
      "Fix in place" [shape=box];
      "Surface verbatim" [shape=doublecircle];
      "Write files" [shape=box];
      "Report path" [shape=doublecircle];

      "Read spec" -> "Read plan";
      "Read plan" -> "Tasks present?";
      "Tasks present?" -> "Emit error and stop" [label="no"];
      "Tasks present?" -> "Derive topic and target" [label="yes"];
      "Derive topic and target" -> "Valid target path?";
      "Valid target path?" -> "Emit error and stop" [label="no"];
      "Valid target path?" -> "Generate fields" [label="yes"];
      "Generate fields" -> "Self-review";
      "Self-review" -> "QA findings?";
      "QA findings?" -> "Fix in place" [label="yes (round < 3)"];
      "Fix in place" -> "Self-review";
      "QA findings?" -> "Surface verbatim" [label="yes (round = 3)"];
      "QA findings?" -> "Write files" [label="no"];
      "Write files" -> "Report path";
  }
  ```

  ## Invocation

  ```
  /team-driven-development:sprint-master <spec-path> <plan-path>
  ```

  - Two positional arguments, both required: absolute or repo-relative paths.
  - Supported equally: direct human invocation, handoff from `team-plan`, F4-gated dispatch from `team-driven-development`.
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "^## Checklist$" skills/sprint-master/SKILL.md && grep -q "digraph sprint_master" skills/sprint-master/SKILL.md && grep -q "^## Invocation$" skills/sprint-master/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/sprint-master/SKILL.md
  git commit -m "feat(sprint-master): add Checklist, Process Flow, and Invocation"
  ```

---

### Task 4: Add Input, Output, and Topic Derivation

**Files:**
- Modify: `skills/sprint-master/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#input

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "^## Input$" skills/sprint-master/SKILL.md && echo INPUT_OK
  grep -q "^## Output Layout$" skills/sprint-master/SKILL.md && echo OUTPUT_OK
  grep -q "stripping the trailing \`.md\`" skills/sprint-master/SKILL.md && echo TOPIC_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "^## Input$" skills/sprint-master/SKILL.md || echo NOT_YET`
  Expected: FAIL with `NOT_YET`
- [ ] Step 3: Append to `skills/sprint-master/SKILL.md`
  ```markdown

  ## Input

  - `<spec-path>`: absolute or repo-relative path to a spec markdown file. Must exist and be readable.
  - `<plan-path>`: absolute or repo-relative path to a plan markdown file. Must exist and be readable. Must contain at least one `### Task N:` heading.

  ## Output Layout

  - `sprints/<topic>/common.md` — feature-level shared fields.
  - `sprints/<topic>/task-N.md` — one file per plan task, numbered to match the plan.
  - `<topic>` is derived from the plan filename by stripping the trailing `.md`.
  - Example: `docs/team-dd/plans/2026-04-18-sprint-master.md` → `sprints/2026-04-18-sprint-master/`.
  - The `sprints/` directory is committed to git.
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "^## Input$" skills/sprint-master/SKILL.md && grep -q "^## Output Layout$" skills/sprint-master/SKILL.md && grep -q "stripping the trailing \`.md\`" skills/sprint-master/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/sprint-master/SKILL.md
  git commit -m "feat(sprint-master): add Input, Output, and topic derivation"
  ```

---

### Task 5: Add common.md and task-N.md schemas

**Files:**
- Modify: `skills/sprint-master/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#common-md-schema

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "^## common.md Schema$" skills/sprint-master/SKILL.md && echo COMMON_OK
  grep -q "^## task-N.md Schema$" skills/sprint-master/SKILL.md && echo TASK_OK
  grep -q "^# Sprint Contract: <feature>$" skills/sprint-master/SKILL.md && echo COMMON_HEADER_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "^## common.md Schema$" skills/sprint-master/SKILL.md || echo NOT_YET`
  Expected: FAIL with `NOT_YET`
- [ ] Step 3: Append to `skills/sprint-master/SKILL.md`
  ````markdown

  ## common.md Schema

  ```markdown
  # Sprint Contract: <feature>

  ## Spec
  <relative path to spec, from repo root>

  ## Plan
  <relative path to plan, from repo root>

  ## Shared Criteria
  - <cross-task rule>

  ## Domain Guidelines
  - <domain>: guidelines/<domain>.md
  ```

  Fields:

  - `Spec` and `Plan` are machine-derived from the input arguments.
  - `Shared Criteria` captures rules that apply to every task in the feature. Derived from the spec's Design and Testing Strategy sections.
  - `Domain Guidelines` lists the `guidelines/<domain>.md` files detected from the plan's file-path patterns using the team-driven-development Phase 0 detection table.

  ## task-N.md Schema

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

  Fields are disjoint from `common.md` (D-strict). `task-N.md` never overrides `common.md`. `Non-Goals` requires at least one entry. `Runtime Validation` is omitted when Profile is `static`. `Browser Validation` is present only when Profile is `browser`.
  ````
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "^## common.md Schema$" skills/sprint-master/SKILL.md && grep -q "^## task-N.md Schema$" skills/sprint-master/SKILL.md && grep -q "^# Sprint Contract: <feature>$" skills/sprint-master/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/sprint-master/SKILL.md
  git commit -m "feat(sprint-master): add common.md and task-N.md schemas"
  ```

---

### Task 6: Add Generation Flow with A-3 and A-4 rulesets verbatim

**Files:**
- Modify: `skills/sprint-master/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#generation-flow

Critical R3 mitigation: transcribe the current A-3 and A-4 rules from `skills/team-driven-development/SKILL.md` verbatim. Do not paraphrase.

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "^## Generation Flow$" skills/sprint-master/SKILL.md && echo FLOW_OK
  grep -q "Effort Scoring" skills/sprint-master/SKILL.md && echo A3_HEADER_OK
  grep -q "Reviewer Profile Selection" skills/sprint-master/SKILL.md && echo A4_HEADER_OK
  grep -q "core/, shared/, security/, auth/" skills/sprint-master/SKILL.md && echo A3_FACTORS_OK
  grep -q "architecture, migration, security, design, refactor" skills/sprint-master/SKILL.md && echo A3_KEYWORDS_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "^## Generation Flow$" skills/sprint-master/SKILL.md || echo NOT_YET`
  Expected: FAIL with `NOT_YET`
- [ ] Step 3: Append to `skills/sprint-master/SKILL.md`
  ```markdown

  ## Generation Flow

  1. Read the spec at `<spec-path>`.
  2. Read the plan at `<plan-path>`.
  3. Parse plan `### Task N:` sections. Extract name, file paths, and test commands.
  4. Derive `<topic>` and target directory `sprints/<topic>/`. Validate path stays within repo root.
  5. For each task: apply **Effort Scoring** and **Reviewer Profile Selection** below; derive Success Criteria, Non-Goals, and Validation.
  6. Derive `common.md` content from the spec's Design + Testing Strategy sections and the detected Domain Guidelines.
  7. Run Contract QA self-review (see below). Max two retry rounds.
  8. Write `common.md` and all `task-N.md` in parallel.

  ### Effort Scoring

  | Factor | +1 when |
  |--------|---------|
  | Files | 4+ modified |
  | Directory | core/, shared/, security/, auth/ |
  | Keywords | architecture, migration, security, design, refactor |
  | Cross-cutting | Touches code other tasks also touch |
  | New subsystem | Creating new module/package |

  Score 0-1 → haiku. Score 2 → sonnet. Score 3+ → opus.

  ### Reviewer Profile Selection

  | Characteristics | Profile |
  |----------------|---------|
  | 1-2 files, logic only, no UI | `static` |
  | Tests, multi-file, integration | `runtime` |
  | UI, CSS, visual | `browser` |
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "^## Generation Flow$" skills/sprint-master/SKILL.md && grep -q "Effort Scoring" skills/sprint-master/SKILL.md && grep -q "Reviewer Profile Selection" skills/sprint-master/SKILL.md && grep -q "core/, shared/, security/, auth/" skills/sprint-master/SKILL.md && grep -q "architecture, migration, security, design, refactor" skills/sprint-master/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/sprint-master/SKILL.md
  git commit -m "feat(sprint-master): add Generation Flow with A-3 and A-4 rulesets"
  ```

---

### Task 7: Add Contract QA Self-Review

**Files:**
- Modify: `skills/sprint-master/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#contract-qa-self-review

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "^## Contract QA Self-Review$" skills/sprint-master/SKILL.md && echo HEADER_OK
  grep -q "AKIA\[0-9A-Z\]{16}" skills/sprint-master/SKILL.md && echo SECRET_OK
  grep -q "Path traversal guard" skills/sprint-master/SKILL.md && echo TRAVERSAL_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "^## Contract QA Self-Review$" skills/sprint-master/SKILL.md || echo NOT_YET`
  Expected: FAIL with `NOT_YET`
- [ ] Step 3: Append to `skills/sprint-master/SKILL.md`
  ```markdown

  ## Contract QA Self-Review

  Mechanical pass before writing files:

  1. **Criterion specificity** — each `Success Criteria` item is specific and verifiable. Reject "Code works"; require conditions like "GET /api/users returns 200 with JSON array".
  2. **Test command completeness** — each test command includes a file path or filter, not a bare runner name.
  3. **Non-Goal presence** — every `task-N.md` declares at least one `Non-Goal`.
  4. **Profile alignment** — `Reviewer Profile` matches the task's file characteristics (e.g., tasks touching `.tsx` cannot be `static`).
  5. **Secret scan** — detect patterns `AKIA[0-9A-Z]{16}`, `Bearer `, `password=`, `api[_-]?key=`. Redact matches with `<REDACTED>` and add a warning line at the top of `common.md`.
  6. **Path traversal guard** — all write targets resolve to `sprints/<topic>/` within the repo root. Reject absolute paths, `..` segments, and any path escaping the target directory.

  Fix findings in place. Max two retry rounds. On third failure, surface findings verbatim to the caller and do not write files.
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "^## Contract QA Self-Review$" skills/sprint-master/SKILL.md && grep -q "AKIA\[0-9A-Z\]{16}" skills/sprint-master/SKILL.md && grep -q "Path traversal guard" skills/sprint-master/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/sprint-master/SKILL.md
  git commit -m "feat(sprint-master): add Contract QA self-review"
  ```

---

### Task 8: Add Error Handling

**Files:**
- Modify: `skills/sprint-master/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#error-handling

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "^## Error Handling$" skills/sprint-master/SKILL.md && echo HEADER_OK
  grep -q "Spec file not found" skills/sprint-master/SKILL.md && echo SPEC_ERR_OK
  grep -q "No tasks found in plan" skills/sprint-master/SKILL.md && echo ZERO_ERR_OK
  grep -q "Invalid target path" skills/sprint-master/SKILL.md && echo PATH_ERR_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "^## Error Handling$" skills/sprint-master/SKILL.md || echo NOT_YET`
  Expected: FAIL with `NOT_YET`
- [ ] Step 3: Append to `skills/sprint-master/SKILL.md`
  ```markdown

  ## Error Handling

  - **Spec file missing / unreadable:** stop. Emit `Spec file not found: <path>`. No partial writes.
  - **Plan file missing / unreadable:** stop. Emit `Plan file not found: <path>`. No partial writes.
  - **Plan has zero tasks:** stop. Emit `No tasks found in plan: <path>`. No partial writes.
  - **Path traversal attempt in derived target:** stop. Emit `Invalid target path: <path>`. No writes.
  - **Secrets detected:** redact with `<REDACTED>` in output files, add a warning at the top of `common.md`, continue. Do not modify the spec or plan.
  - **Self-review fails after two retry rounds:** surface findings verbatim to the caller. Do not write files.
  - **Partial write due to unexpected error:** `sprints/<topic>/` may contain some files but not all. Operation is idempotent — re-run overwrites deterministically.
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "^## Error Handling$" skills/sprint-master/SKILL.md && grep -q "Spec file not found" skills/sprint-master/SKILL.md && grep -q "No tasks found in plan" skills/sprint-master/SKILL.md && grep -q "Invalid target path" skills/sprint-master/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/sprint-master/SKILL.md
  git commit -m "feat(sprint-master): add Error Handling"
  ```

---

### Task 9: Delete templates/sprint-contract-template.md

**Files:**
- Delete: `templates/sprint-contract-template.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#upstream-skill-changes

- [ ] Step 1: Write the failing test
  ```bash
  test ! -e templates/sprint-contract-template.md && echo GONE || echo STILL_PRESENT
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `test ! -e templates/sprint-contract-template.md && echo GONE || echo STILL_PRESENT`
  Expected: FAIL with `STILL_PRESENT`
- [ ] Step 3: Remove the file
  ```bash
  git rm templates/sprint-contract-template.md
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `test ! -e templates/sprint-contract-template.md && echo GONE || echo STILL_PRESENT`
  Expected: PASS with `GONE`
- [ ] Step 5: Commit
  ```bash
  git commit -m "refactor(templates): remove sprint-contract-template.md (schema moves to sprint-master)"
  ```

---

### Task 10: Add sprints layout subsection to guidelines/writing.md

**Files:**
- Modify: `guidelines/writing.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#upstream-skill-changes

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "Sprints (\`sprints/" guidelines/writing.md && echo SECTION_OK
  grep -q "common.md + task-N.md" guidelines/writing.md && echo LAYOUT_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "Sprints (\`sprints/" guidelines/writing.md || echo NOT_YET`
  Expected: FAIL with `NOT_YET`
- [ ] Step 3: Insert a new subsection `### Sprints (\`sprints/<topic>/\`)` after `### Plans (\`docs/team-dd/plans/...\`)` in `guidelines/writing.md` with the content below (use the Edit tool to insert; do not overwrite other subsections):
  ```markdown
  ### Sprints (`sprints/<topic>/`)

  - One directory per feature, mirroring plan filename (without `.md`).
  - `common.md` holds feature-scoped fields: Spec path, Plan path, Shared Criteria, Domain Guidelines.
  - `task-N.md` holds task-scoped fields: Reviewer Profile, Effort Score, Success Criteria, Non-Goals, Validation.
  - Field sets are disjoint between the two files (D-strict). Task files never override common.
  - Generated by `sprint-master`; do not hand-edit unless regenerating via `/team-driven-development:sprint-master`.
  ```
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "Sprints (\`sprints/" guidelines/writing.md && grep -q "common.md + task-N.md" guidelines/writing.md || grep -q "common.md\` holds feature-scoped fields" guidelines/writing.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add guidelines/writing.md
  git commit -m "docs(writing): add sprints layout subsection"
  ```

---

### Task 11: Remove Sprint Contract guidance from deep-brainstorm

**Files:**
- Modify: `skills/deep-brainstorm/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#upstream-skill-changes

- [ ] Step 1: Write the failing test
  ```bash
  grep -c "Sprint Contract" skills/deep-brainstorm/SKILL.md
  ```
  Baseline expected count is non-zero (references to Sprint Contract exist in current spec template guidance).
- [ ] Step 2: Run test to verify it fails
  Run: `grep -n "Sprint Contract" skills/deep-brainstorm/SKILL.md | head`
  Expected: FAIL — prints one or more lines containing "Sprint Contract" that this task must remove
- [ ] Step 3: Edit `skills/deep-brainstorm/SKILL.md` to remove every reference that instructs the spec to embed a `## Sprint Contract` section. Preserve references that describe `sprint-master` as a downstream tool or that appear in historical Decision Log text.
  Remove lines that match patterns like:
  - `- [ ] Sprint Contract block` in checklists
  - `## Sprint Contract` listed as a required spec heading
  - "spec contains a Sprint Contract section" self-review items
- [ ] Step 4: Run test to verify it passes
  Run: `grep -n "## Sprint Contract" skills/deep-brainstorm/SKILL.md | grep -v "sprint-master" || echo CLEAN`
  Expected: PASS with `CLEAN`
- [ ] Step 5: Commit
  ```bash
  git add skills/deep-brainstorm/SKILL.md
  git commit -m "refactor(deep-brainstorm): remove Sprint Contract spec section guidance"
  ```

---

### Task 12: Remove Sprint Contract from quick-plan spec template

**Files:**
- Modify: `skills/quick-plan/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#upstream-skill-changes

- [ ] Step 1: Write the failing test
  ```bash
  grep -c "^## Sprint Contract$" skills/quick-plan/SKILL.md
  grep -c "Sprint Contract present" skills/quick-plan/SKILL.md
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -n "^## Sprint Contract$" skills/quick-plan/SKILL.md`
  Expected: FAIL — prints at least one line (current quick-plan embeds this heading in its spec template)
- [ ] Step 3: Edit `skills/quick-plan/SKILL.md`:
  - Remove the `## Sprint Contract` block from the Spec Structure template.
  - Remove the Self-Review item `**Sprint Contract present** — The spec contains a \`## Sprint Contract\` section with a \`Profile\` of \`static\`, \`runtime\`, or \`browser\`. team-plan fails fast without this.`.
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "^## Sprint Contract$" skills/quick-plan/SKILL.md && echo STILL_THERE || echo CLEAN`
  Expected: PASS with `CLEAN`
- [ ] Step 5: Commit
  ```bash
  git add skills/quick-plan/SKILL.md
  git commit -m "refactor(quick-plan): drop Sprint Contract from spec template"
  ```

---

### Task 13: Document sprints path in solo-review

**Files:**
- Modify: `skills/solo-review/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#upstream-skill-changes

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "sprints/<topic>/task-N.md" skills/solo-review/SKILL.md && echo MENTION_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "sprints/<topic>/task-N.md" skills/solo-review/SKILL.md || echo NOT_YET`
  Expected: FAIL with `NOT_YET`
- [ ] Step 3: Edit the Level 1 section of `skills/solo-review/SKILL.md` to append:
  ```markdown
  - Preferred contract location: `sprints/<topic>/task-N.md` (produced by `sprint-master`). `--contract` accepts this path directly.
  ```
  Insert as a bullet under the Level 1 description.
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "sprints/<topic>/task-N.md" skills/solo-review/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/solo-review/SKILL.md
  git commit -m "docs(solo-review): mention sprints/<topic>/task-N.md in Level 1"
  ```

---

### Task 14: Rewire team-plan to call sprint-master and drop spec-validation

**Files:**
- Modify: `skills/team-plan/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#upstream-skill-changes

This task removes the current `## Sprint Contract` validation, makes team-plan call `sprint-master` via the Skill tool after writing the plan, and adds a `**Sprints:**` header line to the plan template. The bootstrap contract in the sprint-master spec becomes unused after this lands.

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "sprint-master" skills/team-plan/SKILL.md && echo CALLOUT_OK
  grep -q "\\*\\*Sprints:\\*\\*" skills/team-plan/SKILL.md && echo HEADER_OK
  grep -q "Sprint Contract section not found" skills/team-plan/SKILL.md && echo STILL_HAS_OLD_ERROR || echo OLD_ERROR_GONE
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "sprint-master" skills/team-plan/SKILL.md || echo NO_CALLOUT`
  Expected: FAIL with `NO_CALLOUT`
- [ ] Step 3: Edit `skills/team-plan/SKILL.md`:
  - In the HARD-GATE: remove the clause about spec lacking `## Sprint Contract`. Replace with `If the spec or plan cannot be parsed, stop and emit the matching error in Error Handling.`
  - In the Checklist: remove step `**Validate Sprint Contract** — require \`## Sprint Contract\` ...`. Insert after "Write file": `**Invoke sprint-master** — call \`/team-driven-development:sprint-master <spec-path> <plan-path>\` via the Skill tool. On failure, surface the error plus the re-run command to the user.`
  - In the Process Flow DOT graph: remove the "Sprint Contract valid?" diamond and its edges. Add a new node "Invoke sprint-master" between "Write file" and "User approves plan?".
  - In the Plan File Structure template: insert a `**Sprints:** sprints/<topic>/` line immediately below the `**Spec:**` line in the header block.
  - In Input: replace the `MUST contain \`## Sprint Contract\`...` bullets with `Spec and plan paths are the sole validation surface; task extraction happens in sprint-master.`
  - In Error Handling: remove the `## Sprint Contract section missing` and `Profile value not ...` entries. Add `**sprint-master failure:** surface the error and the re-run command \`/team-driven-development:sprint-master <spec-path> <plan-path>\`.`
- [ ] Step 4: Run test to verify it passes
  Run: `grep -q "sprint-master" skills/team-plan/SKILL.md && grep -q "\\*\\*Sprints:\\*\\*" skills/team-plan/SKILL.md && grep -L "Sprint Contract section not found" skills/team-plan/SKILL.md > /dev/null && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/team-plan/SKILL.md
  git commit -m "refactor(team-plan): drop spec Sprint Contract validation; call sprint-master"
  ```

---

### Task 15: Remove Phases A-3/A-4/A-5/A-5.5 and add F4 gate in team-driven-development

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

**Spec ref:** docs/team-dd/specs/2026-04-18-sprint-master-design.md#upstream-skill-changes

This is the largest change. Removes four Phase A sub-phases and adds the F4 gate for missing sprints. Must be last — it changes execution itself.

**Sprint Contract:** Profile: runtime (the modified file drives execution; post-change smoke-runs are required in step 4)

- [ ] Step 1: Write the failing test
  ```bash
  grep -q "^### A-3: Effort Scoring$" skills/team-driven-development/SKILL.md && echo STILL_HAS_A3 || echo A3_GONE
  grep -q "^### A-4: Reviewer Profile$" skills/team-driven-development/SKILL.md && echo STILL_HAS_A4 || echo A4_GONE
  grep -q "^### A-5: Sprint Contract Generation$" skills/team-driven-development/SKILL.md && echo STILL_HAS_A5 || echo A5_GONE
  grep -q "^### A-5.5: Contract QA$" skills/team-driven-development/SKILL.md && echo STILL_HAS_A55 || echo A55_GONE
  grep -q "sprints/<topic>/ not found" skills/team-driven-development/SKILL.md && echo F4_GATE_OK
  grep -q "Read sprints/<topic>/common.md" skills/team-driven-development/SKILL.md && echo B2_READ_OK
  ```
- [ ] Step 2: Run test to verify it fails
  Run: `grep -q "^### A-5: Sprint Contract Generation$" skills/team-driven-development/SKILL.md && echo STILL_HAS_A5 || echo A5_GONE`
  Expected: FAIL with `STILL_HAS_A5`
- [ ] Step 3: Edit `skills/team-driven-development/SKILL.md`:
  - Delete sections `### A-3: Effort Scoring`, `### A-4: Reviewer Profile`, `### A-5: Sprint Contract Generation`, `### A-5.5: Contract QA`, including their tables and body text.
  - After `## Phase A-0: Triage` and before `## Phase A: Pre-delegate`, insert:
    ```markdown
    ## Phase A-0.5: Sprints Gate (F4)

    After Triage, before reading the plan: check that the plan's referenced `sprints/<topic>/` directory exists.

    - If present → proceed to Phase A.
    - If missing → prompt: `sprints/<topic>/ not found. Run sprint-master now? [yes/no]`.
      - On `yes` → invoke `/team-driven-development:sprint-master <spec-path> <plan-path>` via the Skill tool. The spec path is the `**Spec:**` line in the plan header; the plan path is the current plan. Proceed on success.
      - On `no` → abort with `Execution requires Sprint Contract files under sprints/<topic>/. Generate them or invoke with --lite to skip Sprint Contract enforcement.`
    ```
  - In `### A-5` former slot, insert:
    ```markdown
    ### A-5: Read Sprint Contracts

    Read `sprints/<topic>/common.md` and each `sprints/<topic>/task-N.md`. These files are authoritative for Reviewer Profile, Effort Score, Success Criteria, Non-Goals, and Validation. Do not regenerate.
    ```
  - In `### B-2: Dispatch Worker`: replace "Sprint Contract" references in the codebase-context section with "`sprints/<topic>/common.md` + `sprints/<topic>/task-N.md` content". Preserve the existing 2 KB budget rule for reference files.
  - In `### B-4: Review`: same replacement.
  - In `## Lite Mode`: add a line under the mode description: `Lite Mode does not require \`sprints/<topic>/\` and skips the F4 gate.`
- [ ] Step 4: Run test to verify it passes
  Run: `grep -L "^### A-3: Effort Scoring$" skills/team-driven-development/SKILL.md > /dev/null && grep -L "^### A-5.5: Contract QA$" skills/team-driven-development/SKILL.md > /dev/null && grep -q "sprints/<topic>/ not found" skills/team-driven-development/SKILL.md && grep -q "Read sprints/<topic>/common.md" skills/team-driven-development/SKILL.md && echo ALL_OK`
  Expected: PASS with `ALL_OK`
- [ ] Step 5: Commit
  ```bash
  git add skills/team-driven-development/SKILL.md
  git commit -m "refactor(team-dd): remove Phases A-3/A-4/A-5/A-5.5; add F4 sprints gate"
  ```
