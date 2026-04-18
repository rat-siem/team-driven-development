# Sprint Contract: Relocate Sprint Contract Directory

## Spec
docs/team-dd/specs/2026-04-18-relocate-sprints-dir-design.md

## Plan
docs/team-dd/plans/2026-04-18-relocate-sprints-dir.md

## Shared Criteria
- All path string substitutions replace `sprints/` with `docs/team-dd/sprints/` only where the path refers to the Sprint Contract output location; occurrences inside historical plan files under `docs/team-dd/plans/` and spec files under `docs/team-dd/specs/` are not modified.
- After completing both tasks, `rg -l 'sprints/<topic>/' | grep -v '^docs/team-dd/plans/' | grep -v '^docs/team-dd/specs/' | grep -v '^docs/team-dd/sprints/'` must return empty output.
- After completing both tasks, `test ! -e sprints && echo OK` must print `OK` (no root-level `sprints/` directory).
- Each `git mv` is used for all file relocations so git preserves rename history; `mv` is not used in place of `git mv`.
- No write operations touch `docs/team-dd/plans/2026-04-18-*.md` or `docs/team-dd/specs/2026-04-18-*.md` (decision C — historical headers are intentionally untouched).

## Domain Guidelines
- writing: guidelines/writing.md
