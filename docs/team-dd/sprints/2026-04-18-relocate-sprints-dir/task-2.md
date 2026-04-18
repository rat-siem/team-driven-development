# Sprint Contract: Task 2 - Update Sprint Contract path references in docs, skills, and agents

## Reviewer Profile: runtime

## Effort Score: 3 → Model: opus

## Success Criteria
- [ ] `rg -l 'sprints/<topic>/' | grep -v '^docs/team-dd/plans/' | grep -v '^docs/team-dd/specs/' | grep -v '^docs/team-dd/sprints/'` returns empty output — no stale placeholder references outside historical artifacts.
- [ ] `rg -l 'sprints/[0-9]{4}-[0-9]{2}-[0-9]{2}-' | grep -v '^docs/team-dd/plans/' | grep -v '^docs/team-dd/specs/' | grep -v '^docs/team-dd/sprints/'` returns empty output — no stale concrete-path references outside historical artifacts.
- [ ] `rg -n 'docs/team-dd/sprints/<topic>/ not found' README.md docs/README.ja.md skills/team-driven-development/SKILL.md` returns at least one match per file — the F4 prompt literal is updated in all three locations.
- [ ] `rg -n '\bsprints/' CLAUDE.md README.md docs/README.ja.md guidelines/writing.md skills/sprint-master/SKILL.md skills/team-plan/SKILL.md skills/solo-review/SKILL.md skills/team-driven-development/SKILL.md agents/sprint-master.md | rg -v 'docs/team-dd/sprints/'` returns empty output — every remaining `sprints/` mention in the nine target files is prefixed with `docs/team-dd/`.
- [ ] Tests pass: `rg -c 'docs/team-dd/sprints/' agents/sprint-master.md`

## Non-Goals
- This task does not move any files or directories — that is Task 1's responsibility and must be completed first.
- This task does not rewrite `**Sprints:**` header lines in existing plan files under `docs/team-dd/plans/` (decision C).
- This task does not modify spec files under `docs/team-dd/specs/`.
- This task does not modify `scripts/generate-sprint-contract.sh` or any file under `templates/` (the spec explicitly excludes these).
- This task does not modify the newly relocated sprint task files under `docs/team-dd/sprints/` — content inside those files is historical and intentionally left alone.

## Runtime Validation
- `rg -l 'sprints/<topic>/' | grep -v '^docs/team-dd/plans/' | grep -v '^docs/team-dd/specs/' | grep -v '^docs/team-dd/sprints/' || echo "clean"`
- `rg -l 'sprints/[0-9]{4}-[0-9]{2}-[0-9]{2}-' | grep -v '^docs/team-dd/plans/' | grep -v '^docs/team-dd/specs/' | grep -v '^docs/team-dd/sprints/' || echo "clean"`
- `rg -n 'docs/team-dd/sprints/<topic>/ not found' README.md docs/README.ja.md skills/team-driven-development/SKILL.md`
- `rg -n '\bsprints/' CLAUDE.md README.md docs/README.ja.md guidelines/writing.md skills/sprint-master/SKILL.md skills/team-plan/SKILL.md skills/solo-review/SKILL.md skills/team-driven-development/SKILL.md agents/sprint-master.md | rg -v 'docs/team-dd/sprints/' || echo "clean"`
