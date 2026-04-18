# Sprint Contract: Task 1 - Revise Language Policy block in all six SKILL.md files

## Reviewer Profile: runtime

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] `grep -q "Files written to disk (specs, plans, contracts, source code) stay English regardless" skills/quick-brainstorm/SKILL.md` exits 0.
- [ ] `grep -q "Files written to disk (specs, plans, contracts, source code) stay English regardless" skills/deep-brainstorm/SKILL.md` exits 0.
- [ ] `grep -q "Files written to disk (specs, plans, contracts, source code) stay English regardless" skills/team-plan/SKILL.md` exits 0.
- [ ] `grep -q "Files written to disk (specs, plans, contracts, source code) stay English regardless" skills/sprint-master/SKILL.md` exits 0.
- [ ] `grep -q "Files written to disk (specs, plans, contracts, source code) stay English regardless" skills/solo-review/SKILL.md` exits 0.
- [ ] `grep -q "Files written to disk (specs, plans, contracts, source code) stay English regardless" skills/team-driven-development/SKILL.md` exits 0.
- [ ] `grep -q "When the user explicitly requests a translation" skills/quick-brainstorm/SKILL.md` exits 0 (and same for the remaining five files).
- [ ] `grep -q "Don't restate the same rule twice within one file" skills/quick-brainstorm/SKILL.md` exits 0 (and same for the remaining five files).
- [ ] Tests pass: `for f in skills/quick-brainstorm/SKILL.md skills/deep-brainstorm/SKILL.md skills/team-plan/SKILL.md skills/sprint-master/SKILL.md skills/solo-review/SKILL.md skills/team-driven-development/SKILL.md; do grep -q "Files written to disk (specs, plans, contracts, source code) stay English regardless" "$f" && grep -q "When the user explicitly requests a translation" "$f" && grep -q "Don't restate the same rule twice within one file" "$f" || { echo "FAIL: $f"; exit 1; }; done && echo PASS`

## Non-Goals
- Does not modify any agent `.md` files (those are Task 2).
- Does not change chat-prose localization behavior; the first paragraph of Language Policy is preserved verbatim.
- Does not add external file references inside any SKILL.md.

## Runtime Validation
- `for f in skills/quick-brainstorm/SKILL.md skills/deep-brainstorm/SKILL.md skills/team-plan/SKILL.md skills/sprint-master/SKILL.md skills/solo-review/SKILL.md skills/team-driven-development/SKILL.md; do grep -q "Files written to disk (specs, plans, contracts, source code) stay English regardless" "$f" && grep -q "When the user explicitly requests a translation" "$f" && grep -q "Don't restate the same rule twice within one file" "$f" || { echo "FAIL: $f"; exit 1; }; done && echo PASS`
