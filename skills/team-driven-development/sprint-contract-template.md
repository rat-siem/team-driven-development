# Sprint Contract Template

The Lead generates a Sprint Contract for each task during Phase A. This document defines the template and generation rules.

## Template

```markdown
## Sprint Contract: Task N - [Task Name]

### Success Criteria
- [ ] [Criterion derived from plan's acceptance criteria or step descriptions]
- [ ] [Each criterion must be independently verifiable]
- [ ] Tests pass: `[exact test command from plan]`

### Non-Goals
- [Explicit boundary: what this task does NOT do]
- [Adjacent task's responsibility that the Worker must not touch]

### Reviewer Profile: static | runtime | browser

### Runtime Validation (runtime and browser profiles only)
- `[test command]` — expected: PASS
- `[typecheck command]` — expected: PASS
- `[lint command]` — expected: PASS

### Browser Validation (browser profile only)
- [ ] [Navigate to X, verify Y is displayed]
- [ ] [Click Z, verify state change to W]

### Effort Score: [0-5]
### Model Selection: [haiku | sonnet | opus]
### Dependencies: [Task IDs this task depends on, or "none"]
```

## Generation Rules

### Success Criteria

Extract from the plan task:
1. Each `- [ ]` step that produces a verifiable outcome becomes a criterion
2. Test commands from "Run:" lines become test criteria
3. "Expected:" lines define what success looks like
4. If the plan has acceptance criteria, use them directly

**Bad criteria** (too vague):
- "Code works correctly"
- "Tests pass"
- "Implementation is complete"

**Good criteria** (verifiable):
- "GET /api/users returns 200 with JSON array"
- "Tests pass: `pytest tests/test_users.py -v`"
- "New file `src/models/user.py` exports User class with `name: str` and `email: str` fields"

### Non-Goals

Derive from:
1. What adjacent tasks handle (Task N+1's scope is Task N's non-goal)
2. Explicit "don't" instructions in the plan
3. Scope boundaries implied by "Files:" section (files not listed are out of scope)

Always include at least one non-goal. If nothing obvious, use:
- "Do not refactor code outside the listed files"

### Reviewer Profile Selection

| Signals in task | Profile |
|----------------|---------|
| Only logic files, no test commands | `static` |
| Test commands present, multi-file | `runtime` |
| UI/CSS/component files, visual verification | `browser` |
| "verify in browser" in plan text | `browser` |

### Effort Score Calculation

| Factor | Condition | Score |
|--------|-----------|-------|
| File count | 4+ files in task's "Files:" section | +1 |
| Directory risk | Files in core/, shared/, security/, auth/, config/ | +1 |
| Keywords | Task contains: architecture, migration, security, design, refactor | +1 |
| Cross-cutting | Task modifies files also listed in other tasks | +1 |
| New subsystem | Task creates a new directory or module | +1 |

### Model Selection from Effort Score

| Effort Score | Model | Rationale |
|-------------|-------|-----------|
| 0-1 | haiku (cheap) | Mechanical: clear spec, few files |
| 2 | sonnet (standard) | Integration: multi-file, needs judgment |
| 3+ | opus (capable) | Design: complex, cross-cutting |
