# Sprint Contract: Task 4 - Phase A-0 resolution, B-2 Lead-managed worktree, B-6 base-branch cherry-pick

## Reviewer Profile: static

## Effort Score: 3 → Model: opus

## Success Criteria
- [ ] `grep -n "## Base Branch Resolution" skills/team-driven-development/SKILL.md` returns exactly one match inside Phase A-0.
- [ ] `grep -n "git worktree add .claude/worktrees/agent-" skills/team-driven-development/SKILL.md` returns exactly one match in the B-2 section.
- [ ] `grep -n "Cherry-pick to Base Branch" skills/team-driven-development/SKILL.md` returns exactly one match as the B-6 section heading.
- [ ] `grep -n "git checkout <base-branch>" skills/team-driven-development/SKILL.md` returns exactly one match in B-6.
- [ ] `grep -n "--branch ignored" skills/team-driven-development/SKILL.md` returns exactly one match inside the Worktree Check section.
- [ ] `grep -c "Cherry-pick to Main\|isolation: \"worktree\"" skills/team-driven-development/SKILL.md` returns `0`.
- [ ] C-3 Verify section references "base branch" instead of "main".
- [ ] Tests pass: `grep -c "Cherry-pick to Main\|isolation: \"worktree\"" skills/team-driven-development/SKILL.md` (expected: 0)

## Non-Goals
- Do not modify `skills/team-driven-development/prompts/worker-prompt.md` (covered by Task 5).
- Do not modify `agents/worker.md` (covered by Task 6).
- Do not change B-3 through B-5 logic.
- Do not add the `--branch` CLI argument parsing machinery; this task adds the resolution algorithm prose only.
