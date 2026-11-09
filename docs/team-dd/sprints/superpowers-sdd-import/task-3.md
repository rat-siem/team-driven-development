# Sprint Contract: Task 3 - `review-package`

## Reviewer Profile: runtime

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `skills/team-driven-development/scripts/review-package` and `tests/scripts/test-review-package.sh` exist with plan-specified content.
- [ ] `review-package plan.md BASE HEAD` writes `<ws>/review-<base7>..<head7>.diff` containing `## Commits` (all commits in range), `## Files changed`, and `## Diff` (`-U10`); stdout reads `wrote <path>: N commit(s), M bytes`.
- [ ] Optional 4th argument OUTFILE is honored.
- [ ] Empty range (`HEAD HEAD`) exits 3; HEAD not a descendant of BASE exits 3.
- [ ] Unresolvable ref exits 2; wrong arg count exits 2.
- [ ] Tests pass: `bash tests/scripts/test-review-package.sh`
- [ ] Tests pass: `bash tests/scripts/run.sh`

## Non-Goals
- Does not modify `run-workspace` or `tests/scripts/lib.sh` (Task 1).
- Does not derive BASE itself (never `HEAD~1`); caller supplies it.

## Runtime Validation
- `bash tests/scripts/test-review-package.sh`
- `bash tests/scripts/run.sh`
