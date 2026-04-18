# Sprint Contract: quick-plan → quick-brainstorm Rename

## Spec
docs/team-dd/specs/2026-04-18-quick-brainstorm-rename-design.md

## Plan
docs/team-dd/plans/2026-04-18-quick-brainstorm-rename.md

## Shared Criteria
- Behavior-preserving rename only: no change to checklist items, gate wording (other than the self-referential announce string), process-flow logic, handoff contract, or file-path conventions beyond the explicit self-reference edits listed in the spec's `### skills/quick-brainstorm/SKILL.md Internal Edits` table.
- Historical artifacts under `docs/superpowers/**`, `docs/team-dd/specs/2026-04-17-*.md`, `docs/team-dd/plans/2026-04-17-*.md`, `docs/team-dd/specs/2026-04-18-sprint-master-design.md`, and `docs/team-dd/plans/2026-04-18-sprint-master.md` MUST remain byte-identical. They are frozen historical records.
- Directory rename uses `git mv` to preserve rename history; never `rm` + re-add.
- English-only edits everywhere except `docs/README.ja.md`, which is the sanctioned Japanese translation file per the Prompt Language Policy in `CLAUDE.md`.
- Each task produces exactly one commit, following the repo's `type(scope): subject` convention (see recent history: `refactor(team-plan): ...`, `docs(sprint-master): ...`, `fix(sprint-master): ...`).
- No edits outside the files enumerated in the plan's `## File Structure` table; in particular, do not touch `CLAUDE.md`, `.claude-plugin/*.json`, `agents/**`, `templates/**`, or `scripts/**` — all verified free of `quick-plan` tokens.
- All replacements are literal token substitutions (`quick-plan` → `quick-brainstorm`, `Quick Plan` → `Quick Brainstorm`, `quick_plan` → `quick_brainstorm`); do not paraphrase surrounding sentences or adjust whitespace.

## Domain Guidelines
- writing: guidelines/writing.md
