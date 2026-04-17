# README Update for deep-brainstorm / team-plan / sprint-master Design

## Overview

Update `README.md` and `docs/README.ja.md` so they reflect the plugin's new self-contained planning pipeline: `deep-brainstorm`, `team-plan`, `sprint-master`, plus the renamed `quick-brainstorm`. The plugin no longer depends on Superpowers for planning — that framing must be removed from the README.

## Motivation

- Three new skills (`deep-brainstorm`, `team-plan`, `sprint-master`) have landed but are not mentioned in the README.
- The current README says "works best with Superpowers" and routes the thorough path through `superpowers:brainstorming`. With in-house replacements in place, this guidance is misleading.
- The `How It Works → Phase A` section still lists "Generate Sprint Contracts" and "Contract QA" as team-driven-development steps, but these are now owned by `sprint-master` and invoked via the Phase A-0.5 Sprints Gate (F4). The README drifts from the actual skill behavior.
- The renamed `quick-brainstorm` is already referenced, but adjacent wording still treats superpowers as the default thorough option, making the renamed skill look like a workaround rather than the primary self-contained flow.

## Design

### Scope

In scope:
- Edit `README.md` (English, authoritative).
- Edit `docs/README.ja.md` (user-facing translation) to match.
- No changes to skills, CLAUDE.md, or any other file.

Out of scope:
- Rewriting the Phase A-0 Triage / Lite Mode explanations (unchanged).
- Restructuring the "Why Use This" or "When NOT to Use This" sections (unchanged).
- Effort Scoring / Sprint Contract Example / Installation sections (unchanged apart from any incidental rewording only if a neighboring section changes).

### Section-by-Section Changes

#### 1. Key Features

Current list (lines 58–72) omits the three new skills. Update:

- **Keep** the existing `Quick Brainstorm` entry, tweaking the description to clarify the handoff chain (`quick-brainstorm → team-plan → team-driven-development`) and that `team-plan` delegates Sprint Contract generation to `sprint-master`.
- **Add** `Deep Brainstorm` entry: rigorous three-phase variant (Distill / Challenge / Harden) producing an extended spec with Decision Log. Use for vague or high-stakes requirements.
- **Add** `Team Plan` entry: in-plugin implementation-plan writer. Consumes a spec, emits a plan, then invokes `sprint-master`.
- **Add** `Sprint Master` entry: sole owner of Sprint Contract generation. Writes `sprints/<topic>/common.md` and `task-N.md` from a spec + plan. Invoked by `team-plan` or the F4 Sprints Gate.

Ordering: place the four planning skills together, followed by the existing `Solo Review` entry and the rest unchanged.

#### 2. How It Works — Phase A-0.5 and Phase A

Current Phase A (lines 89–96) lists:
1. Read and extract all tasks from the plan
2. Analyze dependencies dynamically
3. Score effort per task
4. Select reviewer profile per task
5. Generate Sprint Contracts
6. Contract QA
7. Determine team composition

Updated Phase A removes items 3–6 (now owned by `sprint-master`, surfaced by the F4 gate) and renumbers. New flow:

- **Add a new section "Phase A-0.5: Sprints Gate (F4)"** between Phase A-0 and Phase A, matching the skill's actual structure:
  - Check that `sprints/<topic>/` exists for the plan.
  - If missing, prompt the user to run `sprint-master`; on yes, invoke it; on no, abort with the standard message.
  - Lite Mode skips this gate.
- **Rewrite Phase A (Pre-delegate)** to reflect that Sprint Contract files already exist:
  1. Read and extract all tasks from the plan.
  2. Read `sprints/<topic>/common.md` and each `task-N.md` (authoritative; do not regenerate).
  3. Analyze dependencies dynamically.
  4. Determine team composition.

The Phase B / Phase C sections remain as-is — they already reference Sprint Contract files from `sprints/<topic>/` implicitly and do not contradict the new flow.

#### 3. Usage

Current structure has three subsections: `With Quick Brainstorm (self-contained)`, `Solo Review (standalone)`, `With Superpowers (thorough)`, and `Standalone`.

Changes:

- **Replace the preface line** "This plugin works best with Superpowers but can be used standalone." (line 153) with a self-contained framing: "This plugin is self-contained — all planning, implementation, and review skills ship with it." No mention of Superpowers in the preface.
- **Rename** "With Superpowers (thorough)" → "With Deep Brainstorm (thorough)". Update its body:
  - Flow: `deep-brainstorm → team-plan → team-driven-development`.
  - Describe when to use: vague or high-stakes requirements, multiple approach comparisons, section-by-section design approval.
  - Do not mention Superpowers. `deep-brainstorm` is the in-plugin rigorous variant; it stands on its own without reference to the skill it replaces.
- **Leave** `With Quick Brainstorm (self-contained)` mostly intact; tweak the description to note that `quick-brainstorm` hands off to `team-plan`, which hands off to `sprint-master` before returning.
- **Leave** `Solo Review (standalone)` and `Standalone` unchanged.

#### 4. Japanese README (`docs/README.ja.md`)

Mirror every change above with equivalent Japanese wording. Section headings, bullet structure, and line order must match the English README so future diffs are reviewable side-by-side.

Specifically:
- 主な機能: add `Deep Brainstorm` / `Team Plan` / `Sprint Master` entries, update `Quick Brainstorm` entry.
- 動作フロー: add "Phase A-0.5: スプリントゲート (F4)" section; rewrite Phase A.
- 使い方: delete the "Superpowers と組み合わせて使うのが最適" preface; rename "Superpowers と併用（じっくり）" → "Deep Brainstorm と併用（じっくり）"; update flow diagram.

### Wording Rules

- Never remove the rationale for keeping the self-contained flow (matches the plugin's direction).
- Preserve every skill's invocation form exactly as the skill's `Invocation` section states it (`/team-driven-development:<skill>`), so the README doubles as a pointer to the canonical command.
- Cross-reference skills by name once at first use; subsequent mentions can use plain names without decoration.
- For the Japanese file, keep the existing tone (です・ます with technical terms in English where they already are).

### Error Handling

None — this is a documentation edit. No commands run.

### Testing Strategy

- **Link sanity**: read each section after the edit and verify no broken cross-references (e.g., nothing still points at a skill that doesn't exist).
- **Consistency check**: diff English README against Japanese README line-structure. They should have the same section order and the same number of bullets per section.
- **Self-review**: run the quick-brainstorm spec self-review (placeholder / consistency / scope / ambiguity).

## File Changes

| File | Status | Purpose |
| --- | --- | --- |
| `README.md` | Modify | Add three new skills to Key Features; replace "With Superpowers" with "With Deep Brainstorm"; add Phase A-0.5; rewrite Phase A. |
| `docs/README.ja.md` | Modify | Mirror the English README changes in Japanese, same section order. |
| `docs/team-dd/specs/2026-04-18-readme-update-skills-design.md` | Create | This spec. |
| `docs/team-dd/plans/2026-04-18-readme-update-skills.md` | Create (by team-plan) | Implementation plan. |
| `sprints/2026-04-18-readme-update-skills/` | Create (by sprint-master) | Sprint Contract files, when executed. |
| Skill files, CLAUDE.md, marketplace.json | Not modified | Out of scope. |
