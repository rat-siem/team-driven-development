# Sprint Contract: README Quick Brainstorm Flow Fix

## Spec
docs/team-dd/specs/2026-04-18-readme-quick-brainstorm-flow-fix-design.md

## Plan
docs/team-dd/plans/2026-04-18-readme-quick-brainstorm-flow-fix.md

## Shared Criteria
- Flow notation must list only skills the user invokes manually; skills called as internal subagents (notably `sprint-master`) are excluded from arrow chains.
- `sprint-master` must not appear adjacent to an arrow (`→` or `->`) in `README.md` or `docs/README.ja.md` after any edit.
- English and Japanese READMEs must remain structurally parallel at modified locations: same number of bullets, same paragraph order, same conveyed facts.
- Skill names use code formatting on first use per section; subsequent mentions may use plain names.
- No changes to CLAUDE.md, skill files, marketplace.json, or any file outside `README.md` and `docs/README.ja.md`.

## Domain Guidelines
- docs: guidelines/docs.md
