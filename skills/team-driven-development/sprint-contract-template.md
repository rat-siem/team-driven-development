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

### Guidelines
- [domain]: guidelines/[domain].md
<!-- Include one line per relevant domain. Omit this section if no guidelines exist. -->

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

### Guidelines Integration

When generating a Sprint Contract, the Lead checks for `guidelines/{domain}.md` files relevant to the task:

1. Determine which domains the task touches (using the Domain Detection Table from SKILL.md Phase 0)
2. For each domain with an existing guideline file, add it to the Guidelines section
3. If no guideline files exist for the task's domains, omit the Guidelines section entirely

The Lead reads the full content of each referenced guideline file and includes it in the Worker's dispatch prompt alongside the Sprint Contract.

## Contract QA

After generating each Sprint Contract, the Lead runs a QA check before dispatching the Worker. See SKILL.md Phase A-5.5 for the full checklist. Key validations:

1. Success Criteria must be specific and verifiable (not vague)
2. Test commands must include file paths or filters
3. At least one Non-Goal must be defined
4. Reviewer Profile must match task characteristics
5. Dependencies must be stated as preconditions if the dependent task is not yet complete
6. Guidelines section references only files that exist in `guidelines/`
