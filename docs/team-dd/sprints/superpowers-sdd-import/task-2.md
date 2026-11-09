# Sprint Contract: Task 2 - `task-brief`

## Reviewer Profile: runtime

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `skills/team-driven-development/scripts/task-brief` and `tests/scripts/test-task-brief.sh` exist with plan-specified content.
- [ ] `task-brief plan.md 2` on `skills/sprint-master/fixtures/valid-plan.md` writes `<ws>/task-2-brief.md` starting with `### Task 2: Add greeter CLI` and containing no `Task 1:` text; stdout contains the path.
- [ ] `task-brief p10.md 1 OUTFILE` extracts Task 1 only; `Task 10` content is excluded.
- [ ] A `### Task` heading inside a code fence does not end or start a task section.
- [ ] Task number not found exits 3 (no output file left); missing plan or wrong arg count exits 2.
- [ ] Tests pass: `bash tests/scripts/test-task-brief.sh`
- [ ] Tests pass: `bash tests/scripts/run.sh`

## Non-Goals
- Does not modify `run-workspace` or `tests/scripts/lib.sh` (Task 1).
- Does not parse task metadata beyond extracting the section text.

## Runtime Validation
- `bash tests/scripts/test-task-brief.sh`
- `bash tests/scripts/run.sh`
