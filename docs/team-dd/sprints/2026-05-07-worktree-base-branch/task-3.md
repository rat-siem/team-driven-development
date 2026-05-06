# Sprint Contract: Task 3 - Read and emit base branch in team-plan

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -c "Base branch:" skills/team-plan/SKILL.md` returns a value ≥ 4 (section heading, Checklist item, algorithm block, plan header template).
- [ ] `grep -n "Resolve base branch" skills/team-plan/SKILL.md` returns exactly one match inside the Checklist section.
- [ ] `grep -n "## Base Branch Resolution" skills/team-plan/SKILL.md` returns exactly one match positioned before `## Plan File Structure`.
- [ ] The Base Branch Resolution algorithm references reading the spec's `**Base branch:**` field as step 2 (prefer spec value, skip prompt).
- [ ] The plan header template in `## Plan File Structure` contains `**Base branch:** <resolved branch>` as the last metadata line.
- [ ] Checklist items are renumbered sequentially 1–8 with no gaps.
- [ ] Tests pass: `grep -c "Base branch:" skills/team-plan/SKILL.md` (expected: ≥ 4)

## Non-Goals
- Do not modify `skills/quick-brainstorm/SKILL.md` or `skills/deep-brainstorm/SKILL.md`.
- Do not change plan task generation logic.
- Do not alter the sprint-master dispatch step.
