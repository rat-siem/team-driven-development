# Sprint Contract: Task 1 - Merge team-plan's plan gate and execution handoff into Plan Confirmation Gate

## Reviewer Profile: static

## Effort Score: 2 → Model: sonnet

## Success Criteria
- [ ] `grep -c '^## Plan Confirmation Gate$' skills/team-plan/SKILL.md` returns `1`
- [ ] `grep -c 'Ready to execute with team-driven-development' skills/team-plan/SKILL.md` returns `1`
- [ ] `grep -c '^## User Plan Gate$' skills/team-plan/SKILL.md` returns `0`
- [ ] `grep -c '^## Execution Handoff$' skills/team-plan/SKILL.md` returns `0`
- [ ] `grep -c 'Any changes before we proceed' skills/team-plan/SKILL.md` returns `0`
- [ ] `grep -c '"User approves plan?"' skills/team-plan/SKILL.md` returns `0`
- [ ] `grep -c '"Propose execution"' skills/team-plan/SKILL.md` returns `0`
- [ ] `grep -q '"Plan Confirmation Gate" \[shape=diamond\]' skills/team-plan/SKILL.md` exits 0
- [ ] Checklist contains exactly one step 7 reading `Plan Confirmation Gate — revise on free-form feedback; execute on confirmation; stop on decline.`
- [ ] Tests pass: `grep -c '^## Plan Confirmation Gate$' skills/team-plan/SKILL.md && grep -c 'Ready to execute with team-driven-development' skills/team-plan/SKILL.md && ! grep -q '^## User Plan Gate$' skills/team-plan/SKILL.md && ! grep -q '^## Execution Handoff$' skills/team-plan/SKILL.md && ! grep -q 'Any changes before we proceed' skills/team-plan/SKILL.md && ! grep -q '"User approves plan?"' skills/team-plan/SKILL.md && ! grep -q '"Propose execution"' skills/team-plan/SKILL.md && grep -q '"Plan Confirmation Gate" \[shape=diamond\]' skills/team-plan/SKILL.md && echo OK`

## Non-Goals
- Does not change any section of `skills/team-plan/SKILL.md` other than the two replaced sections, checklist steps 7-8, and the Process Flow DOT block.
- Does not modify `skills/quick-brainstorm/SKILL.md` or any other file.
- Does not unify the merged prompt wording with `sprint-master`'s existing single-prompt wording.
- Does not introduce runtime behavior changes beyond what the new section text specifies.
