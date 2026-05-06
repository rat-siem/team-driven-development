# Sprint Contract: Task 7 - Mirror plan's Base branch into Sprint Contract common.md

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -n "## Base branch" agents/sprint-master.md` returns exactly one match inside the `common.md` schema section.
- [ ] The `## Base branch` section appears between `## Plan` and `## Shared Criteria` in the schema block.
- [ ] `grep -n "copied verbatim from the plan" agents/sprint-master.md` returns exactly one match in the field-derivation bullets.
- [ ] The derivation note states the section is omitted when the plan has no `**Base branch:**` field (back-compat clause present).
- [ ] Tests pass: `grep -c "## Base branch\|copied verbatim from the plan" agents/sprint-master.md` (expected: 2)

## Non-Goals
- Do not modify the `task-N.md` schema in `agents/sprint-master.md`.
- Do not add base-branch resolution logic to `agents/sprint-master.md`; it only mirrors the value, never resolves it.
- Do not modify any other agent or skill file.
