# Sprint Contract: Task 1 - Insert the canonical Language Policy block into every SKILL.md

## Reviewer Profile: static

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] None of the six SKILL.md files contain a `## Language Policy` heading before the edit (confirmed by `grep -c '^## Language Policy$'` returning `0` for each file).
- [ ] After edit, all six files contain the exact three-paragraph canonical block: heading `## Language Policy`, paragraph beginning "Render fixed user-facing text", paragraph beginning "Keep literal regardless of language", paragraph beginning "Detection: default to the dominant language".
- [ ] In `skills/quick-brainstorm/SKILL.md`, `skills/deep-brainstorm/SKILL.md`, `skills/team-plan/SKILL.md`, and `skills/sprint-master/SKILL.md`: `## Language Policy` appears before `## Checklist`. Verified by: `awk '/^## Language Policy$/{lp=NR} /^## Checklist$/{ch=NR} END{exit !(lp && ch && lp<ch)}' <file>` exits 0.
- [ ] In `skills/solo-review/SKILL.md`: `## Language Policy` appears before `## Arguments`. Verified by: `awk '/^## Language Policy$/{lp=NR} /^## Arguments$/{ar=NR} END{exit !(lp && ar && lp<ar)}' skills/solo-review/SKILL.md` exits 0.
- [ ] In `skills/team-driven-development/SKILL.md`: `## Language Policy` appears before `## When to Use`. Verified by: `awk '/^## Language Policy$/{lp=NR} /^## When to Use$/{wtu=NR} END{exit !(lp && wtu && lp<wtu)}' skills/team-driven-development/SKILL.md` exits 0.
- [ ] Tests pass: `for f in skills/quick-brainstorm/SKILL.md skills/deep-brainstorm/SKILL.md skills/team-plan/SKILL.md skills/sprint-master/SKILL.md skills/solo-review/SKILL.md skills/team-driven-development/SKILL.md; do grep -qF "## Language Policy" "$f" && grep -qF "Render fixed user-facing text in the user's conversation language" "$f" && grep -qF "Keep literal regardless of language" "$f" && grep -qF "Detection: default to the dominant language" "$f"; done && echo ALL_OK`

## Non-Goals
- This task does not validate runtime translation behavior — it only inserts the policy block text.
- This task does not modify `guidelines/writing.md` (that is Task 2).
- This task does not change any skill's procedural logic, checklist steps, or gate flow.
- This task does not introduce any new files or directories.
