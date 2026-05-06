# Sprint Contract: Task 6 - Restrict Worker to provided worktree path

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -n "Operate exclusively inside" agents/worker.md` returns exactly one match inside the `## Rules` section.
- [ ] The new rule is the first bullet in the `## Rules` list (appears before "Implement exactly what the Sprint Contract specifies").
- [ ] The rule text references the `## Worktree` block in the dispatch prompt explicitly.
- [ ] Tests pass: `grep -c "Operate exclusively inside" agents/worker.md` (expected: 1)

## Non-Goals
- Do not modify `skills/team-driven-development/prompts/worker-prompt.md` (covered by Task 5).
- Do not change any section of `agents/worker.md` other than the `## Rules` list.
- Do not alter the TDD or escalation rules.
