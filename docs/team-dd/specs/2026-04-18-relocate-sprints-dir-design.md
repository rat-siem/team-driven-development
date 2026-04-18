# Relocate Sprint Contract Directory Design

## Overview

Move the Sprint Contract output directory from the repository root (`sprints/<topic>/`) to `docs/team-dd/sprints/<topic>/`, aligning it with the existing `docs/team-dd/specs/` and `docs/team-dd/plans/` layout. Update every documentation, skill, and agent reference, and physically relocate existing sprint directories. Historical plan `**Sprints:**` header lines are intentionally left unchanged.

## Motivation

- Specs and plans already live under `docs/team-dd/`; sprints are the third generated artifact in that family and belong alongside them.
- A top-level `sprints/` entry at the repo root pollutes the project listing and suggests it is a first-class subsystem (like `skills/` or `agents/`), which it is not.
- Co-locating all team-driven-development runtime outputs under `docs/team-dd/` makes the ignore-rule and backup-rule story uniform.

## Design

### Target Path

- New sprint output root: `docs/team-dd/sprints/`
- Per-feature directory: `docs/team-dd/sprints/<topic>/`
- `<topic>` derivation rule is unchanged: plan filename minus trailing `.md`.
- Example: `docs/team-dd/plans/2026-04-18-sprint-master.md` → `docs/team-dd/sprints/2026-04-18-sprint-master/`.

### Reference Updates

Every string of the form `sprints/<topic>/` or bare `sprints/` that describes the Sprint Contract output location is rewritten to `docs/team-dd/sprints/<topic>/` (or `docs/team-dd/sprints/`).

The following files contain such references and must be updated:

| File | Occurrences | Notes |
|---|---|---|
| `CLAUDE.md` | 1 | Source-file policy bullet |
| `README.md` | 4 | Sprint Master entry + Sprints Gate description |
| `docs/README.ja.md` | 4 | Japanese mirror of README |
| `guidelines/writing.md` | 1 section heading | `### Sprints (...)` |
| `skills/sprint-master/SKILL.md` | 1 | Front-matter-adjacent description paragraph |
| `skills/team-plan/SKILL.md` | 3 | Input/Output narrative + plan-file template `**Sprints:**` line |
| `skills/solo-review/SKILL.md` | 1 | Contract detection Level 1 |
| `skills/team-driven-development/SKILL.md` | 8 | Phase A-0.5 (F4 gate), Phase A-5, Phase B-2, Phase B-4 |
| `agents/sprint-master.md` | ~10 | Description, HARD-GATE, checklist, output layout, schemas, QA, error handling, report |

Replacement is a mechanical string substitution of `sprints/` → `docs/team-dd/sprints/` **in the contexts where the path refers to the Sprint Contract output location**. Do not blindly replace all occurrences — guard against false positives:

- Skip occurrences inside fenced code blocks that are documentation examples of historical file trees (none found; document the rule for the Worker).
- Skip the `**Sprints:** sprints/...` lines inside existing plan files under `docs/team-dd/plans/` (decision C — past plans remain untouched).
- Skip any matches inside historical sprint task files (`docs/team-dd/sprints/*/*.md` after move) whose content documents a past source-file policy. Reviewers should leave these alone.

### Physical Relocation of Existing Directories

Existing top-level `sprints/` contains six per-feature subdirectories (content ranges from fully populated to empty-shell). All of them are moved with `git mv` so git preserves history:

```bash
mkdir -p docs/team-dd/sprints
git mv sprints/* docs/team-dd/sprints/
rmdir sprints  # should be empty after the move
```

After the move, the repo has no root-level `sprints/` directory at all.

### Historical Plan Headers (Intentionally Untouched)

Three existing plans under `docs/team-dd/plans/` contain a `**Sprints:** sprints/<topic>/ ...` header line that still points at the old location:

- `docs/team-dd/plans/2026-04-18-language-policy-file-scope.md`
- `docs/team-dd/plans/2026-04-18-readme-update-skills.md`
- `docs/team-dd/plans/2026-04-18-consolidate-plan-execute-gate.md`

Per decision C, these lines are **not** rewritten. The rationale: those plans have already been executed; rewriting their headers to match a post-hoc relocation would create a misleading impression that the plan itself was authored against the new path. Readers comparing git history will see the old header alongside the move commit and understand the sequence.

This creates one consistency gap: if someone re-executes one of these old plans, the team-driven-development F4 gate derives the target directory from the plan filename (not the header line), finds it at the new location, and proceeds correctly. The header line is narrative only and does not drive behavior.

### Error Handling

This is a documentation-and-move change — no new runtime error paths. Existing error messages that embed the path (`Invalid target path: <path>`, `sprints/<topic>/ not found. Run sprint-master now?`, etc.) update mechanically with the path strings.

One edge case to verify: the team-driven-development F4 gate's prompt text (`sprints/<topic>/ not found. Run sprint-master now? [yes/no]`) should now read `docs/team-dd/sprints/<topic>/ not found. Run sprint-master now? [yes/no]` so the user sees the real path.

### Testing Strategy

No unit tests exist for these paths — validation is textual and structural.

1. **Zero stale placeholder references** — after all edits, searching for the bare placeholder `sprints/<topic>/` outside historical artifacts returns nothing:
   ```bash
   rg -l 'sprints/<topic>/' \
     | grep -v '^docs/team-dd/plans/' \
     | grep -v '^docs/team-dd/specs/' \
     | grep -v '^docs/team-dd/sprints/'
   ```
   Expected: empty output.
2. **Zero stale concrete references** — same check for concrete per-feature paths. Any remaining `sprints/<YYYY-MM-DD-...>/` references must live inside historical artifacts (plans/specs skipped per decision C) or inside the relocated sprint task files themselves:
   ```bash
   rg -l 'sprints/[0-9]{4}-[0-9]{2}-[0-9]{2}-' \
     | grep -v '^docs/team-dd/plans/' \
     | grep -v '^docs/team-dd/specs/' \
     | grep -v '^docs/team-dd/sprints/'
   ```
   Expected: empty output.
3. **No root-level sprints/** — after move: `test ! -e sprints && echo OK`.
4. **New location populated** — `ls docs/team-dd/sprints/` lists the six relocated topics.
5. **Git history preserved** — `git log --follow docs/team-dd/sprints/2026-04-18-language-policy-file-scope/task-3.md` shows the original commit(s).
6. **Agent dry run** (manual, optional) — invoke `sprint-master` with any test spec+plan pair and confirm output lands at `docs/team-dd/sprints/<topic>/` and not at the old root.

## File Changes

| File | Status | Purpose |
|---|---|---|
| `CLAUDE.md` | Modify | Update source-file policy bullet to new path |
| `README.md` | Modify | Update Sprint Master entry + Sprints Gate prompts |
| `docs/README.ja.md` | Modify | Mirror English updates |
| `guidelines/writing.md` | Modify | Update `### Sprints (...)` section heading and intro |
| `skills/sprint-master/SKILL.md` | Modify | Update description paragraph |
| `skills/team-plan/SKILL.md` | Modify | Update Input/Output narrative and plan-template `**Sprints:**` line |
| `skills/solo-review/SKILL.md` | Modify | Update Level 1 contract location hint |
| `skills/team-driven-development/SKILL.md` | Modify | Update Phase A-0.5, A-5, B-2, B-4 references and F4 prompt text |
| `agents/sprint-master.md` | Modify | Update description, HARD-GATE, checklist, schemas, QA, error handling, report lines |
| `sprints/*` (6 directories) | Move | `git mv` to `docs/team-dd/sprints/` |
| `sprints/` (root dir) | Delete | Empty after move; removed |
| `docs/team-dd/sprints/` | Create | New parent directory |
| `docs/team-dd/plans/2026-04-18-*.md` | Not modified | Historical `**Sprints:**` headers left untouched (decision C) |
| `docs/team-dd/specs/2026-04-18-*.md` | Not modified | Historical specs' references left untouched (same rationale) |
| `scripts/generate-sprint-contract.sh` | Not modified | Does not hardcode the sprints path |
| `templates/*` | Not modified | No `sprints/` references present |
