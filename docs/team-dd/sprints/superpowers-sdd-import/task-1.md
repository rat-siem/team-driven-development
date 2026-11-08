# Sprint Contract: Task 1 - Test harness and `run-workspace`

## Reviewer Profile: runtime

## Effort Score: 2 → Model: sonnet

## Success Criteria
- [ ] `tests/scripts/lib.sh`, `tests/scripts/run.sh`, `tests/scripts/test-run-workspace.sh`, `skills/team-driven-development/scripts/run-workspace` exist with plan-specified content.
- [ ] `bash skills/team-driven-development/scripts/run-workspace docs/plans/feat.md` prints `<repo-root>/.team-dd/runs/feat` and writes `plan-path` containing `docs/plans/feat.md`.
- [ ] Repeated invocation prints the same path; `.team-dd/.gitignore` contains `*` and is not overwritten when already present.
- [ ] A plan with the same basename in a different directory resolves to `.team-dd/runs/feat-other`.
- [ ] Missing plan file or zero args exits 2; `.team-dd` does not appear in `git status --porcelain`.
- [ ] `tests/scripts/run.sh` runs every `tests/scripts/test-*.sh` and exits 1 if any fails.
- [ ] Tests pass: `bash tests/scripts/test-run-workspace.sh`
- [ ] Tests pass: `bash tests/scripts/run.sh`

## Non-Goals
- Does not implement `task-brief` or `review-package`.
- Does not modify SKILL.md, prompts, agents, or READMEs.
- Does not add a root `.gitignore` entry for `.team-dd/`.

## Runtime Validation
- `bash tests/scripts/test-run-workspace.sh`
- `bash tests/scripts/run.sh`
