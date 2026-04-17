# Rename `quick-plan` Skill to `quick-brainstorm` Design

## Overview

Rename the `quick-plan` skill to `quick-brainstorm` across the repository. Behavior is unchanged — this is a pure identifier rename that aligns the skill name with its actual role (lightweight brainstorm that produces a spec and delegates plan generation to `team-plan`).

## Motivation

- In a prior session, `team-plan` was introduced as a dedicated plan-generation skill. `quick-plan` now delegates all plan generation to `team-plan` and only owns the lightweight-dialogue → spec phase.
- The current name `quick-plan` no longer reflects the skill's actual responsibility. Its real role is a *brainstorm* — infer context, ask minimally, emit a spec — which makes `quick-brainstorm` the accurate name.
- Renaming now, before further features layer on top of the current name, prevents the drift from compounding.

## Design

### Scope

Pure rename. No behavior, checklist, process-flow logic, gate wording (other than the self-referential announce string), handoff contract, or file-path conventions change. Historical documents in `docs/` that reference the old name are left untouched so prior specs/plans remain readable as they were written.

### Directory Move

Move the skill directory using `git mv` so git tracks the rename as a rename (not delete + add):

```
skills/quick-plan/            → skills/quick-brainstorm/
skills/quick-plan/SKILL.md    → skills/quick-brainstorm/SKILL.md
```

The directory contains only `SKILL.md`, so a single `git mv skills/quick-plan skills/quick-brainstorm` is sufficient.

### `skills/quick-brainstorm/SKILL.md` Internal Edits

After the directory move, edit the file's self-references:

| Line | Before | After |
|---|---|---|
| 2 (frontmatter) | `name: quick-plan` | `name: quick-brainstorm` |
| 6 (H1) | `# Quick Plan` | `# Quick Brainstorm` |
| 8 (intro prose) | `quick-plan infers what it can` | `quick-brainstorm infers what it can` |
| 10 (announce) | `"I'm using quick-plan to generate a spec and hand off to team-plan."` | `"I'm using quick-brainstorm to generate a spec and hand off to team-plan."` |
| 29 (digraph) | `digraph quick_plan {` | `digraph quick_brainstorm {` |

The `description` field (line 3) contains no `quick-plan` / `Quick Plan` substring and is left unchanged.

### Other In-Repo Reference Updates

Update every non-historical reference so a post-rename `grep` returns nothing outside `docs/`:

| File | Lines | Change |
|---|---|---|
| `skills/team-plan/SKILL.md` | 63 | `quick-plan` → `quick-brainstorm` |
| `skills/team-driven-development/SKILL.md` | 14, 22 | `quick-plan` → `quick-brainstorm` |
| `skills/solo-review/SKILL.md` | 167 | `quick-plan` → `quick-brainstorm` (both occurrences on the line) |
| `skills/deep-brainstorm/SKILL.md` | 270, 278 | `quick-plan` → `quick-brainstorm` |
| `README.md` | 59, 155, 158, 161 (2 occurrences), 250 | `quick-plan` / `Quick Plan` → `quick-brainstorm` / `Quick Brainstorm` (preserve case style per occurrence) |
| `docs/README.ja.md` | 58, 154, 157, 160 (2 occurrences), 249 | Same as `README.md` |
| `guidelines/writing.md` | 84, 85 | `quick-plan` → `quick-brainstorm` |

Verified to contain **no** occurrences (no edits needed):
- `CLAUDE.md`
- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `agents/**`, `templates/**`, `scripts/**`

### Historical Documents — Not Modified

The following files contain `quick-plan` references but represent past-session artifacts (specs/plans for the original skill introduction and for work completed under the old name). They are preserved verbatim for historical accuracy:

- `docs/superpowers/specs/2026-04-15-quick-plan-design.md`
- `docs/superpowers/plans/2026-04-15-quick-plan.md`
- `docs/superpowers/plans/2026-04-16-*.md`, `docs/superpowers/specs/2026-04-16-*.md`
- `docs/team-dd/specs/2026-04-17-*.md`, `docs/team-dd/plans/2026-04-17-*.md`
- `docs/team-dd/specs/2026-04-18-sprint-master-design.md`, `docs/team-dd/plans/2026-04-18-sprint-master.md`

These documents describe the state of the world when they were written. Rewriting them would destroy that context.

### Prompt Language Policy Note

`CLAUDE.md` mandates English for all plugin files except user-facing translations. This rename introduces no new natural-language text, so the policy is unaffected. `Quick Brainstorm` (the new H1 / inline display name) remains English.

### Error Handling

Not applicable — this is a static edit task with no runtime component.

### Testing Strategy

Verification is purely textual. After the rename is applied, run from the repo root:

```sh
grep -rn 'quick-plan\|quick_plan\|Quick Plan' . \
  --exclude-dir=.git \
  --exclude-dir=docs
```

**Expected result:** empty output. Any hit outside `docs/` indicates an unfinished rename.

A second sanity check confirms the new name is discoverable:

```sh
grep -rln 'quick-brainstorm' skills/ README.md docs/README.ja.md guidelines/
```

Must list at least `skills/quick-brainstorm/SKILL.md` and every file edited in the table above.

No automated tests exist for this skill, and the skill's runtime behavior is unchanged, so no test additions are required.

## File Changes

### Moved (directory rename via `git mv`)

| From | To |
|---|---|
| `skills/quick-plan/` | `skills/quick-brainstorm/` |
| `skills/quick-plan/SKILL.md` | `skills/quick-brainstorm/SKILL.md` |

### Modified after move

| File | Purpose |
|---|---|
| `skills/quick-brainstorm/SKILL.md` | Frontmatter name, H1, intro prose, announce string, digraph identifier |
| `skills/team-plan/SKILL.md` | Update `quick-plan` reference in integration note |
| `skills/team-driven-development/SKILL.md` | Update two `quick-plan` references in "No plan available" flow |
| `skills/solo-review/SKILL.md` | Update `quick-plan` reference in criteria-source list |
| `skills/deep-brainstorm/SKILL.md` | Update two `quick-plan` references (deferral note, "Coexists with") |
| `README.md` | Update all occurrences (feature list, section heading, code sample, prose with 2 occurrences, rationale) |
| `docs/README.ja.md` | Update all occurrences mirroring `README.md` |
| `guidelines/writing.md` | Update two `quick-plan` references in the Plan / Spec definitions |

### New

None.

### Not Modified

| File / Path | Reason |
|---|---|
| `CLAUDE.md` | No occurrences |
| `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | No occurrences |
| `agents/**`, `templates/**`, `scripts/**` | No occurrences |
| `docs/superpowers/**`, `docs/team-dd/specs/2026-04-17-*`, `docs/team-dd/plans/2026-04-17-*`, `docs/team-dd/specs/2026-04-18-sprint-master-design.md`, `docs/team-dd/plans/2026-04-18-sprint-master.md` | Historical artifacts; preserve original text |
