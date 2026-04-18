# Sprint Contract: Task 2 - Remove quick-brainstorm's Execution Handoff block

## Reviewer Profile: static

## Effort Score: 2 → Model: sonnet

## Success Criteria
- [ ] `grep -c '^## Execution Handoff$' skills/quick-brainstorm/SKILL.md` returns `0`
- [ ] `grep -c 'Propose execution' skills/quick-brainstorm/SKILL.md` returns `0`
- [ ] `grep -c 'Plan complete and saved' skills/quick-brainstorm/SKILL.md` returns `0`
- [ ] `grep -c 'combined plan/execute gate' skills/quick-brainstorm/SKILL.md` returns at least `1`
- [ ] `grep -q '"Hand off to team-plan" \[shape=doublecircle\]' skills/quick-brainstorm/SKILL.md` exits 0
- [ ] Checklist step 7 reads `Return — \`team-plan\` owns the combined plan/execute gate; quick-brainstorm completes on team-plan return`
- [ ] The `## Handoff to team-plan` section ownership statement references `combined plan/execute gate (including invocation of \`team-driven-development\` on confirmation)`
- [ ] Tests pass: `! grep -q '^## Execution Handoff$' skills/quick-brainstorm/SKILL.md && ! grep -q 'Propose execution' skills/quick-brainstorm/SKILL.md && ! grep -q 'Plan complete and saved' skills/quick-brainstorm/SKILL.md && grep -q 'combined plan/execute gate' skills/quick-brainstorm/SKILL.md && grep -q '"Hand off to team-plan" \[shape=doublecircle\]' skills/quick-brainstorm/SKILL.md && echo OK`

## Non-Goals
- Does not change any section of `skills/quick-brainstorm/SKILL.md` other than the `Execution Handoff` section (removed), checklist step 7, the `Handoff to team-plan` ownership statement, and the Process Flow DOT block.
- Does not modify `skills/team-plan/SKILL.md` or any other file.
- Does not alter the `## Key Principles` section or any section before `## Handoff to team-plan`.
- Does not add new sections; the removal of `## Execution Handoff` leaves no replacement section.
