# README Restructure Design

## Overview

Rewrite `README.md` (and its Japanese mirror `docs/README.ja.md`) so that the plugin's skills, their intended workflow order, and skill selection guidance become the spine of the document. Restore an explicit acknowledgement that the plugin's spec/plan format is compatible with Superpowers' — including Superpowers' `brainstorming` as a legitimate alternative entry point — so users already in the Superpowers ecosystem know they can interoperate.

## Motivation

- The current README reads as a dense list of features mixed with architecture narrative; skills appear in multiple sections (Key Features, How It Works, Usage) without a single ordered introduction.
- When a user arrives at the repo, there is no clear answer to the two most common questions: *"which skill do I invoke first?"* and *"which skill is right for my situation?"*
- Prior edits stripped every mention of Superpowers to assert a self-contained posture. That decision over-corrected on the interop point: spec/plan formats are compatible, and a user arriving with a Superpowers-format spec should be told so plainly. The restored framing is interop guidance, not a claim about lineage or extension.
- A user-facing restructure is the right time to lift skill-selection guidance out of paragraphs and into a dedicated comparison table.

## Design

### Target Structure (both READMEs)

The new top-level section order is:

1. **Title + language switch link** — unchanged.
2. **Tagline** — one-sentence pitch (kept from current intro).
3. **Architecture** — the role diagram + four role bullets (Lead / Worker / Reviewer / Architect), unchanged from current content, just renamed from "What It Does" to "Architecture".
4. **Why Use This** — kept.
5. **When NOT to Use This** — kept.
6. **Skills** *(new, replaces "Key Features")* — the core reorganization. See "Skills section" below.
7. **Choosing a Skill** *(new)* — the 使い分け matrix. See "Choosing a Skill section" below.
8. **Workflow** *(new, small)* — a single pipeline diagram showing `spec → plan → sprint contracts → execution` and where each skill sits on that pipeline. This is a visual summary of what the Skills + Choosing sections established in prose.
9. **Usage** — concrete invocations, regrouped to match the three entry-point flows defined in "Choosing a Skill". See "Usage section" below.
10. **How It Works** — the Phase 0 / A-0 / A-0.5 / A / B / C descriptions. Kept verbatim; moved below Usage because it is reference material, not onboarding.
11. **Sprint Contract Example** — kept.
12. **Effort Scoring** — kept.
13. **Design Note: Intentional YAGNI Violation on Deferral** — kept.
14. **Installation** — kept.
15. **Updating** — kept.
16. **Requirements** — kept.
17. **License** — kept.

The "Key Features" flat list is dissolved: every bullet either moves into the Skills section (if it describes a skill) or into the role/architecture narrative (if it describes a cross-cutting capability like Review Ledger or Worktree isolation). No Key Features heading in the new layout.

### Skills section

Header: `## Skills`

Preamble: state that every skill ships with the plugin and is invokable as `/<skill-name>`. The section is split into two groups: **Core pipeline** (skills you invoke in sequence for a normal feature) and **Supporting skills** (standalone tools you reach for only in specific situations — each core-pipeline skill internally uses these when needed, so you rarely call them directly).

Each skill gets a level-3 heading with a 2–5-line description covering: what it does, when to reach for it, what it hands off to, and (where applicable) the `/slash` invocation.

#### Core pipeline

Listed in workflow order. A normal run uses one spec skill, then `team-plan`, then `team-driven-development`.

Stage 1 — **Spec generation** (pick one):

- `### quick-brainstorm` — Lightweight spec generator. Infers what it can from the repo and asks only genuinely ambiguous points. Produces a full-quality spec, then hands off to `team-plan`. Default choice for well-scoped work.
- `### deep-brainstorm` — Three-phase spec generator (Distill / Challenge / Harden). Produces an extended spec with Decision Log, Unresolved Items, and Checklist Snapshot. Use when requirements are vague or the decision trail must survive into the artifact.
- `### superpowers:brainstorming` *(external, optional)* — The Superpowers project's own brainstorming skill. Specs it produces are compatible with `team-plan` because the spec format is shared. Reach for it when you already work in the Superpowers ecosystem or prefer its dialogue style.

Stage 2 — **Plan generation**:

- `### team-plan` — Consumes an approved spec from `docs/team-dd/specs/` and writes a token-optimized plan under `docs/team-dd/plans/`. After plan approval, automatically invokes `sprint-master` to generate Sprint Contract files. Invoked as `/team-plan <spec-path>`.

Stage 3 — **Execution**:

- `### team-driven-development` — The orchestration skill. Runs Lead/Worker/Reviewer/Architect roles against the plan + Sprint Contracts, including the Reviewer pass — you do not need `solo-review` as part of this flow. Supports Lite and Full modes (auto-triaged, override with `--lite` / `--full`). If Sprint Contract files are missing it invokes `sprint-master` through the F4 gate automatically. Invoked as `/team-driven-development <plan-path>`.

#### Supporting skills

These are invoked automatically by the core pipeline. Call them directly only in the situations listed below.

- `### sprint-master` — Sole owner of Sprint Contract generation. Reads a spec + plan and writes `docs/team-dd/sprints/<topic>/common.md` and `task-N.md`. Normally invoked by `team-plan` after plan approval, or by `team-driven-development`'s F4 Sprints Gate. Call it directly only when:
  - you are bringing your own hand-written plan (skipping `team-plan`) and need Sprint Contract files for it, or
  - you edited a plan after contracts were generated and want to regenerate contracts against the updated plan.
  Invocation: `/sprint-master <spec-path> <plan-path>`.
- `### solo-review` — Runs the Reviewer agent on its own. Auto-detects review target (staged / uncommitted / branch diff) and adapts criteria (Sprint Contract → plan-derived → generic). The main pipeline already reviews every Worker's output, so `solo-review` is **not** part of the standard flow. Call it directly when:
  - you want an extra review pass with a different angle (e.g., force `--profile runtime` or `--profile browser` after a `static` review),
  - you re-review code that team-driven-development has already approved, for a fresh concern (security, performance, refactor readiness),
  - you want to review a specific commit range or path (`/solo-review HEAD~3..HEAD`, `/solo-review src/api/`),
  - you are reviewing code that was written outside the team pipeline (hand-written changes, external contributions), or
  - you want to review against a specific Sprint Contract on demand (`--contract <path>`).
  Invocation: `/solo-review [range|path] [--profile …] [--contract …]`.

#### Cross-cutting capabilities

A short bullet list at the end of the Skills section, mentioning engine-level features that aren't skills but show up repeatedly: Effort Scoring, Worktree isolation, Worktree-aware execution, Review Ledger, Domain Guidelines, Sprint Contract QA, Dynamic dependency analysis, Parallel execution, Three-tier review (`static` / `runtime` / `browser`), Adaptive process selection (Lite / Full). One sentence each.

### Choosing a Skill section

Header: `## Choosing a Skill`

Two artifacts:

**Entry-point flow diagram** — a tiny ASCII decision text for the core pipeline:

```
What do you have?
├── A rough idea, clear scope               → /quick-brainstorm
├── A vague or high-stakes requirement      → /deep-brainstorm
├── A spec already (yours or Superpowers')  → /team-plan <spec>
└── A plan already (+ Sprint Contracts)     → /team-driven-development <plan>
```

**Core pipeline table** — the skills you pick between for normal work:

| When you... | Use | Output | Next |
|---|---|---|---|
| Have a clear request, want a spec fast | `quick-brainstorm` | spec | `team-plan` |
| Have a vague/high-stakes requirement | `deep-brainstorm` | extended spec with Decision Log | `team-plan` |
| Already live in the Superpowers ecosystem | `superpowers:brainstorming` | Superpowers-format spec | `team-plan` (compatible) |
| Have an approved spec | `team-plan` | plan + Sprint Contracts (via `sprint-master`) | `team-driven-development` |
| Have a plan + Sprint Contracts | `team-driven-development` | implemented, reviewed code | — |

One short paragraph after the table: *"If you are unsure between `quick-brainstorm` and `deep-brainstorm`, default to `quick-brainstorm`; it will surface ambiguities that warrant escalating. If you are unsure between this plugin's brainstorming skills and `superpowers:brainstorming`, either works — choose by familiarity."*

**Supporting skills table** — when to reach for the standalone tools the core pipeline already uses internally:

| Situation | Use | Why not the core pipeline? |
|---|---|---|
| You hand-wrote a plan and need Sprint Contracts | `sprint-master` | `team-plan` generates contracts automatically from its own plans; only run `sprint-master` yourself when skipping `team-plan`. |
| You edited the plan after contracts were generated | `sprint-master` | Regenerate contracts against the updated plan. |
| You want a review from a different angle after team-driven-development approved | `solo-review --profile <runtime\|browser>` | The core pipeline reviews each task against its contract; `solo-review` adds a fresh-angle pass on top. |
| You are reviewing code not produced by the pipeline (hand-written, external PR) | `solo-review` | The core pipeline only reviews Worker output. |
| You want to review a specific range or path on demand | `solo-review HEAD~3..HEAD` / `solo-review src/api/` | Targeted ad-hoc review. |
| You want to force a specific Sprint Contract against current changes | `solo-review --contract <path>` | Run the Reviewer with an explicit contract outside the team flow. |

### Workflow section

Header: `## Workflow`

One pipeline diagram that distinguishes the core flow (solid arrows) from the supporting skills (dashed / parenthesized), so readers see at a glance that `sprint-master` and `solo-review` are auxiliary:

```
  spec                  plan                        execution
    │                     │                             │
quick-brainstorm ───►  team-plan  ──────────────►  team-driven-development
deep-brainstorm   ───►     │                             │
superpowers:      ───►     │                             │
  brainstorming            │                             │
                           ▼                             │
                     sprint-master                       │
                 (auto; invoked by team-plan             │
                  and team-driven-development's          │
                  F4 Sprints Gate)                       │
                                                         ▼
                                              (Reviewer runs inside
                                               team-driven-development)

  Off-pipeline, manual only:
    sprint-master  — when you hand-wrote a plan or edited it after contracts were made
    solo-review    — extra review pass, code outside the pipeline, or targeted range/path
```

Three-sentence prose summary below the diagram reaffirms: specs live in `docs/team-dd/specs/`, plans in `docs/team-dd/plans/`, contracts in `docs/team-dd/sprints/<topic>/`, and each stage has a single owner. Note explicitly that review is **inside** `team-driven-development` — `solo-review` is not a pipeline stage.

### Usage section

Header: `## Usage`

Restructured from the current four-subsection layout into two top-level groups, matching Skills:

**Core pipeline** — these are the normal flows:

- `### Standard flow (quick)` — `/quick-brainstorm <request>` → approve spec → `team-plan` runs → approve plan → `team-driven-development` runs. Show the command sequence. Describe the auto-handoffs (including that `team-plan` invokes `sprint-master` automatically, and that `team-driven-development` runs the Reviewer internally).
- `### Thorough flow (deep or Superpowers)` — shows both `deep-brainstorm → team-plan → team-driven-development` and `superpowers:brainstorming → team-plan → team-driven-development` as equivalent thorough-path options. Include an explicit note: specs produced by Superpowers' `brainstorming` feed directly into this plugin's `team-plan` because the spec format is shared.
- `### Bring your own plan` — if you already have a plan in the task format (example block kept from current README), you can invoke `team-driven-development` directly. Note that the F4 Sprints Gate will invoke `sprint-master` for you if Sprint Contract files are missing, or you can run `sprint-master` yourself first.

**Supporting skills (manual)** — shown after the core pipeline so they read as auxiliary, not primary:

- `### Regenerating Sprint Contracts (`sprint-master`)` — two situations: (1) you hand-wrote a plan and skipped `team-plan`; (2) you edited a plan after contracts were generated. Show `/sprint-master <spec-path> <plan-path>`.
- `### Ad-hoc review (`solo-review`)` — explain that the core pipeline already reviews each Worker's output. List the situations where `solo-review` is still useful (extra angle, code outside the pipeline, targeted range/path, forced profile, explicit contract) with the override options from the current README preserved.

The current "This plugin is self-contained" preface line is replaced with: *"Every skill ships with the plugin. Skills interoperate with Superpowers' `brainstorming` and `writing-plans` because the spec/plan formats are shared."*

### Error Handling

Not applicable — documentation only.

### Testing Strategy

Lightweight, manual:

- **Presence checks** — after the edit, run `grep` on both READMEs to confirm: (a) `superpowers:brainstorming` appears in the Skills section and the Choosing core-pipeline table, (b) Skills contains both a "Core pipeline" and a "Supporting skills" sub-grouping, (c) `sprint-master` and `solo-review` appear only under Supporting skills in Skills and under a Supporting section in Usage (never in the core-pipeline table or the entry-point flow diagram), (d) each of the six plugin skills has a `###` heading in Skills, (e) no mention of `superpowers:subagent-driven-development` or "extension of" framing is reintroduced anywhere.
- **No orphan references** — confirm `Key Features` heading is removed in both files, and no bullet from the former Key Features list was silently dropped without being placed elsewhere (track each bullet's destination).
- **Bilingual parity** — diff section count between `README.md` and `docs/README.ja.md`; they must have the same top-level section order and the same skill list.
- **Render sanity** — open both files in a Markdown preview and confirm the diagram blocks, tables, and fenced code blocks render without structural issues.

No automated tests; this is a documentation rewrite.

## File Changes

| Path | Change | Notes |
|---|---|---|
| `README.md` | Modified | Full restructure per the target structure above. |
| `docs/README.ja.md` | Modified | Japanese mirror restructured in lockstep; section headings, skill order, table, and diagrams translated but structurally identical. |
| `CLAUDE.md` | Not modified | The existing sentence about "historical specs from the legacy Superpowers planning skill" is accurate and stays. |
| Skills (`skills/**`) | Not modified | This change is README-only. Skill descriptions already cover behavior. |
