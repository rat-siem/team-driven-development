# Sprint Contract: Task 5 - Drop isolation flag, add Worktree block in worker prompt

## Reviewer Profile: static

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] `grep -c "isolation:" skills/team-driven-development/prompts/worker-prompt.md` returns `0`.
- [ ] `grep -n "## Worktree" skills/team-driven-development/prompts/worker-prompt.md` returns exactly one match inside the Agent tool prompt block.
- [ ] The `## Worktree` block contains all four labels: `Path:`, `Branch:`, `Base:`, and "All commands run inside this path. Do not modify files outside it."
- [ ] The `## Worktree` block appears before the `## Task` block in the prompt body.
- [ ] Tests pass: `grep -c "isolation:" skills/team-driven-development/prompts/worker-prompt.md` (expected: 0)

## Non-Goals
- Do not modify `skills/team-driven-development/SKILL.md` (covered by Task 4).
- Do not change the `## Sprint Contract` section of the worker prompt.
- Do not add any new Agent tool parameters beyond dropping `isolation:`.
