# Sprint Contract: Task 1 - Add Base Branch Resolution to quick-brainstorm

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -c "Base branch:" skills/quick-brainstorm/SKILL.md` returns a value ≥ 4 (section heading, Checklist item, algorithm block, spec template).
- [ ] `grep -n "Resolve base branch" skills/quick-brainstorm/SKILL.md` returns exactly one match inside the Checklist section.
- [ ] `grep -n "## Base Branch Resolution" skills/quick-brainstorm/SKILL.md` returns exactly one match as a standalone section.
- [ ] The spec template in the file contains `**Base branch:** <resolved branch>` immediately after the `# [Feature Name] Design` heading line.
- [ ] Checklist items are renumbered sequentially 1–8 with no gaps.
- [ ] Tests pass: `grep -c "Base branch:" skills/quick-brainstorm/SKILL.md` (expected: ≥ 4)

## Non-Goals
- Do not add base-branch resolution logic to any file other than `skills/quick-brainstorm/SKILL.md`.
- Do not modify the runtime behavior of git commands; this task edits Markdown skill instructions only.
- Do not change the Clarification Logic section content beyond inserting the preceding section.
