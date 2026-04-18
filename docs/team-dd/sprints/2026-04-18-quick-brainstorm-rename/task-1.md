# Sprint Contract: Task 1 - Rename skill directory and update self-references

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `skills/quick-plan/` no longer exists on disk, and `git log --follow --oneline -1 skills/quick-brainstorm/SKILL.md` traces back to a prior `skills/quick-plan/SKILL.md` path (confirms `git mv` was used, not `rm` + re-add).
- [ ] `skills/quick-brainstorm/SKILL.md` line 2 is exactly `name: quick-brainstorm` and line 3 (the `description:` field) is byte-identical to its pre-rename content.
- [ ] The file contains `# Quick Brainstorm` as its sole H1 heading and `digraph quick_brainstorm {` in the Process Flow section.
- [ ] The announce sentence in the file is exactly: `"I'm using quick-brainstorm to generate a spec and hand off to team-plan."`
- [ ] `grep -nE 'quick-plan|Quick Plan|quick_plan' skills/quick-brainstorm/SKILL.md` produces no output.
- [ ] Exactly one commit is added, following `type(scope): subject` style; the commit touches only `skills/quick-brainstorm/SKILL.md` (plus the implicit rename record) and no other path.
- [ ] Tests pass: `bash -c 'test ! -e skills/quick-plan && test -f skills/quick-brainstorm/SKILL.md && grep -q "^name: quick-brainstorm$" skills/quick-brainstorm/SKILL.md && grep -q "^# Quick Brainstorm$" skills/quick-brainstorm/SKILL.md && grep -qF "I'"'"'m using quick-brainstorm to generate a spec and hand off to team-plan." skills/quick-brainstorm/SKILL.md && grep -q "^digraph quick_brainstorm {$" skills/quick-brainstorm/SKILL.md && ! grep -qE "quick-plan|Quick Plan|quick_plan" skills/quick-brainstorm/SKILL.md'`

## Non-Goals
- Do NOT edit any file outside `skills/quick-brainstorm/SKILL.md`; external references (other SKILL.md files, README.md, docs/README.ja.md, guidelines/writing.md) are Task 2's scope.
- Do NOT modify the `description:` frontmatter line (line 3). It contains no `quick-plan` token and the spec explicitly keeps it unchanged.
- Do NOT alter checklist items, Process Flow edges, Clarification Logic, Spec Generation rules, gate wording (except the announce string), or handoff contract inside the file.
- Do NOT rename via `rm` + re-add or via `mv` (non-git). Rename history must survive `git log --follow`.
