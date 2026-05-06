# Sprint Contract: Task 2 - Add Base Branch Resolution to deep-brainstorm

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -c "Base branch:" skills/deep-brainstorm/SKILL.md` returns a value ≥ 4 (section heading, Checklist item, algorithm block, spec template).
- [ ] `grep -n "Resolve base branch" skills/deep-brainstorm/SKILL.md` returns exactly one match inside the Checklist section.
- [ ] `grep -n "## Base Branch Resolution" skills/deep-brainstorm/SKILL.md` returns exactly one match as a standalone section positioned before `## Three Phases`.
- [ ] The extended spec template contains `**Base branch:** <resolved branch>` immediately after the `# [Feature Name] Design` heading line.
- [ ] Checklist items are renumbered sequentially 1–11 with no gaps.
- [ ] Tests pass: `grep -c "Base branch:" skills/deep-brainstorm/SKILL.md` (expected: ≥ 4)

## Non-Goals
- Do not modify `skills/quick-brainstorm/SKILL.md` or any other file.
- Do not alter the Three Phases section content.
- Do not change the subagent reviewer dispatch logic.
