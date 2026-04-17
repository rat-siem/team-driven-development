# Prompt Deduplication and Compression Design

## Overview

Eliminate ~139 lines of duplicated or verbose content across the Team-Driven Development plugin's skill and agent prompts. Two categories of change: structural duplication (same content in 2+ files) and local verbosity (overweight formatting for simple decisions). Core behavior is unchanged — this is a prompt refactor only.

## Motivation

### Structural Duplication (High Priority)

- **`skills/team-driven-development/sprint-contract-template.md`** (115 lines) is orphaned. `SKILL.md:202` references `templates/sprint-contract-template.md` (the root template), not the skill-embedded copy. A repository-wide `grep` for the skill-embedded path finds only historical references under `docs/superpowers/` (frozen planning archives); no live prompt reads this file. The embedded copy also duplicates Effort Score, Profile selection, and Domain Detection tables that already live in `SKILL.md` Phase A-3 / A-4 / Phase 0.
- **Severity → verdict mapping** appears in both `agents/reviewer.md:17-25` and `SKILL.md:264-270` with identical semantics. The Reviewer subagent loads `agents/reviewer.md` automatically on dispatch, and the Lead — who runs static reviews directly — has already read `agents/reviewer.md` as part of the Team section. Two copies create drift risk with no benefit.

### Local Verbosity (Medium Priority)

- `SKILL.md:14-22` renders a binary decision ("have a plan?") as a 9-line DOT digraph.
- `SKILL.md:111-127` presents Quick Score and Mode Selection as two adjacent sections that share a score dimension — they are more readable merged.
- `agents/worker.md:45-50` "Status Definitions" restates the four status labels already listed in the Report bullet at line 31, in a separate section.

### Non-goals

- No behavior change. Dispatch, review, contract generation, worktree isolation, and cherry-pick flows all remain identical.
- `scripts/effort-scoring.sh` and `scripts/generate-sprint-contract.sh` are out of scope. They are orphan utilities (no prompt references them), but removing them is a user-visible action; defer to a separate decision.
- `templates/sprint-contract-template.md` (the root template, which IS referenced) is unchanged.
- Dispatch prompts under `skills/team-driven-development/prompts/` are unchanged — already minimal.

## Design

### Change 1 — Delete orphan Sprint Contract template

**Target:** `skills/team-driven-development/sprint-contract-template.md` (delete file).

**Pre-change verification:** `grep -r "skills/team-driven-development/sprint-contract-template.md"` returns only matches under `docs/superpowers/` (historical plans); no live prompt file references this path.

**Impact:** 115 lines removed. No prompt update required because no live prompt reads the file.

### Change 2 — Consolidate Severity/Verdict mapping into one source

**Target:** `skills/team-driven-development/SKILL.md:264-270` (the "Verdict Rules" table and its heading).

**Replacement:**

```markdown
### Verdict Rules

Severity → verdict mapping is defined in `agents/reviewer.md`. The Lead applies the same rules when running a static-profile review.
```

**Why `agents/reviewer.md` is the source of truth:** Reviewer subagents load it automatically on dispatch (Changes of this shape were already made in commit `b148812` for dispatch role-definitions). Lead also reads the Team section in SKILL.md which anchors on agent file names.

**Impact:** ~7 lines removed.

### Change 3 — Replace "When to Use" digraph with a single sentence

**Target:** `skills/team-driven-development/SKILL.md:14-22`.

**Replacement:**

```markdown
**When to use:** You have an implementation plan to execute. No plan → suggest the `quick-plan` skill first.
```

The existing line "Simple plans automatically trigger Lite Mode suggestion" (L26) remains as the follow-up sentence; the digraph encoded exactly the same decision.

**Impact:** 9 lines → 1 line = ~8 lines removed.

### Change 4 — Merge Quick Score and Mode Selection

**Target:** `skills/team-driven-development/SKILL.md:111-127`.

**Replacement:** A single section that presents the factor table and immediately maps the total to mode.

```markdown
### Quick Score → Mode Selection

| Factor | 0 | +1 | +2 |
|--------|---|----|----|
| Tasks | 1-2 | 3-4 | 5+ |
| Files | ≤3 | 4-6 | 7+ |
| Domains | single | multiple | — |
| Design keywords (architecture, migration, security, API design) | — | present | — |

- `--lite` → Lite Mode. If total > 1: `"Plan has Quick Score [N] — typically Full Mode. Proceeding Lite as requested."`
- `--full` → Full Mode, skip proposal.
- Auto: Score ≤ 1 → propose Lite. Score > 1 → Full.

**Proposal (auto, Score ≤ 1):** "This plan has [N] tasks touching [M] files — lightweight enough for direct execution. Use Lite Mode? **Yes** — direct execution + single review. **No** — full team process."
```

**Impact:** ~17 lines → ~13 lines = ~4 lines removed, with improved readability.

### Change 5 — Inline Status labels into Worker Report

**Target:** `agents/worker.md:45-50` (the standalone "Status Definitions" section).

**Approach:** Delete the "Status Definitions" section. Replace the single-line `Status:` bullet in the Report section (currently L31) with a status block that embeds each label's definition.

**Replacement for the existing `- **Status:** ...` bullet:**

```markdown
- **Status:** one of
  - `DONE` — Complete, tests pass, self-review clean
  - `DONE_WITH_CONCERNS` — Complete but doubts about correctness/scope/approach
  - `NEEDS_CONTEXT` — Missing information. Specify what you need
  - `BLOCKED` — Cannot complete. Describe blocker and what you tried
```

**Impact:** ~5-6 lines net removal (status defs deduplicated into the Report bullet).

### Change 6 — Version bump

**Target:** `.claude-plugin/plugin.json`.

Bump `0.11.1 → 0.11.2` (patch). Rationale: prompt refactor, no behavior change, no breaking change.

### Error Handling

Prompts are declarative artifacts with no runtime error paths. No error handling changes.

### Testing Strategy

Prompts are not programmatically testable; verification is manual and evidentiary.

1. **Orphan-reference check (Change 1):** `grep -r "skills/team-driven-development/sprint-contract-template.md" --exclude-dir=docs/superpowers --exclude-dir=.git` returns no results after deletion.
2. **Cross-reference integrity (Change 2):** `agents/reviewer.md:17-25` still contains the Severity table before any SKILL.md edit is made; the new pointer text in SKILL.md names the correct file path.
3. **SKILL.md structural check (Changes 3, 4):** Open `SKILL.md` in a markdown viewer (or `bat`) and confirm all tables render, the `## Arguments` section still follows the `## When to Use` section, and Phase A-0 `Quick Score → Mode Selection` heading is present.
4. **Worker prompt smoke test (Change 5):** Invoke `team-driven-development` on a trivial one-file task (e.g., add a README sentence) in Lite Mode skipped, Full Mode path. Confirm Worker dispatches and returns a report with a parsable `Status:` block that uses one of the four labels.
5. **Version bump check (Change 6):** `.claude-plugin/plugin.json` version field is `"0.11.2"`.

## File Changes

| File | Change |
|------|--------|
| `skills/team-driven-development/sprint-contract-template.md` | **Delete** (orphan, 115 lines) |
| `skills/team-driven-development/SKILL.md` | Replace digraph (L14-22), merge Quick Score + Mode Selection (L111-127), replace Verdict Rules table with pointer (L264-270) |
| `agents/worker.md` | Inline Status labels into Report section; delete "Status Definitions" section |
| `.claude-plugin/plugin.json` | Bump version `0.11.1` → `0.11.2` |
| Not modified | `templates/sprint-contract-template.md`, `agents/reviewer.md`, `agents/architect.md`, `skills/quick-plan/SKILL.md`, `skills/solo-review/SKILL.md`, all dispatch prompts, all guideline templates, `scripts/*.sh` |

**Estimated line reduction:** ~139 lines total (115 + 7 + 8 + 4 + 5).
