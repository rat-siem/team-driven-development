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

One-line preamble: state that every skill ships with the plugin, is invokable as `/<skill-name>`, and appears below in the order of a typical end-to-end flow.

Skills are presented in **workflow order**, grouped by pipeline stage. Each skill gets a level-3 heading and a 2–5-line description covering: what it does, when to reach for it, what it hands off to, and (where applicable) the `/slash` invocation.

Stage 1 — **Spec generation**:

- `### quick-brainstorm` — Lightweight spec generator. Infers what it can from the repo and asks only genuinely ambiguous points. Produces a full-quality spec, then hands off to `team-plan`. Default choice for well-scoped work.
- `### deep-brainstorm` — Three-phase spec generator (Distill / Challenge / Harden). Produces an extended spec with Decision Log, Unresolved Items, and Checklist Snapshot. Use when requirements are vague or the decision trail must survive into the artifact.
- `### superpowers:brainstorming` *(external, optional)* — The Superpowers project's own brainstorming skill. Specs it produces are compatible with `team-plan` because the spec format is shared. Reach for it when you already work in the Superpowers ecosystem or prefer its dialogue style.

Stage 2 — **Plan generation**:

- `### team-plan` — Consumes an approved spec from `docs/team-dd/specs/` and writes a token-optimized plan under `docs/team-dd/plans/`. After plan approval, automatically invokes `sprint-master` to generate Sprint Contract files. Invoked as `/team-plan <spec-path>`.

Stage 3 — **Sprint Contract generation**:

- `### sprint-master` — Sole owner of Sprint Contract generation. Reads a spec + plan and writes `docs/team-dd/sprints/<topic>/common.md` and `task-N.md`. Usually invoked automatically by `team-plan`, but can run standalone via `/sprint-master <spec-path> <plan-path>`, or on demand from the F4 Sprints Gate inside `team-driven-development`.

Stage 4 — **Execution**:

- `### team-driven-development` — The orchestration skill. Runs Lead/Worker/Reviewer/Architect roles against the plan + Sprint Contracts. Supports Lite and Full modes (auto-triaged, override with `--lite` / `--full`). Invoked as `/team-driven-development <plan-path>`.

Stage 5 — **Standalone review** (not in the main pipeline):

- `### solo-review` — Runs the Reviewer agent on its own. Auto-detects review target (staged / uncommitted / branch diff) and adapts criteria (Sprint Contract → plan-derived → generic). Use for ad-hoc review without running the full team workflow. Invoked as `/solo-review [range|path]`.

Cross-cutting capabilities (Effort Scoring, Worktree isolation, Review Ledger, Domain Guidelines, Sprint Contract QA, Dynamic dependency analysis, Parallel execution, Three-tier review, Worktree-aware execution, Adaptive process selection) are **not** listed in Skills. They appear either:
- inline in the relevant skill's description if specific to one skill (e.g., Effort Scoring lives under `team-driven-development`, Adaptive process selection lives under `team-driven-development`), or
- as a short bullet list at the end of the Skills section under a sub-heading `### Cross-cutting capabilities` that mentions the remaining engine-level features in one sentence each.

### Choosing a Skill section

Header: `## Choosing a Skill`

Two artifacts:

**Entry-point flow diagram** — a tiny ASCII/Mermaid-free decision text like:

```
What do you have?
├── A rough idea, clear scope           → /quick-brainstorm
├── A vague or high-stakes requirement  → /deep-brainstorm
├── A spec already (yours or Superpowers') → /team-plan <spec>
├── A plan already                      → /team-driven-development <plan>
└── A diff to review, no plan           → /solo-review
```

**Comparison table** (columns: skill, best for, output, hands off to):

| When you... | Use | Output | Next |
|---|---|---|---|
| Have a clear request, want a spec fast | `quick-brainstorm` | spec | `team-plan` |
| Have a vague/high-stakes requirement | `deep-brainstorm` | extended spec with Decision Log | `team-plan` |
| Already live in the Superpowers ecosystem | `superpowers:brainstorming` | Superpowers-format spec | `team-plan` (compatible) |
| Have an approved spec | `team-plan` | plan + Sprint Contracts (via `sprint-master`) | `team-driven-development` |
| Have a plan + Sprint Contracts | `team-driven-development` | implemented, reviewed code | — |
| Only need a code review on current changes | `solo-review` | structured verdict | — |

One short paragraph after the table covers defaults: *"If you are unsure between `quick-brainstorm` and `deep-brainstorm`, default to `quick-brainstorm`; it will surface ambiguities that warrant escalating. If you are unsure between this plugin's brainstorming skills and `superpowers:brainstorming`, either works — choose by familiarity."*

### Workflow section

Header: `## Workflow`

One small diagram placing each skill on the pipeline, for readers who prefer a visual summary:

```
      spec           plan              sprint contracts          execution
        │              │                       │                     │
quick-brainstorm ──► team-plan ──► sprint-master (auto) ──► team-driven-development
deep-brainstorm  ──►   ▲                        ▲                     │
superpowers:     ──►   │                        │                     │
  brainstorming        │                        │                     │
                       └── /team-plan <spec>    └── /sprint-master    └── /solo-review (ad-hoc, off-pipeline)
```

Three-sentence prose summary below the diagram reaffirms: specs live in `docs/team-dd/specs/`, plans in `docs/team-dd/plans/`, contracts in `docs/team-dd/sprints/<topic>/`, and each stage has a single owner.

### Usage section

Header: `## Usage`

Restructured from the current four-subsection layout into three scenario-based subsections that match the Choosing table:

- `### Standard flow (quick)` — `/quick-brainstorm <request>` → approve spec → `team-plan` runs → approve plan → `team-driven-development` runs. Show the command sequence. Describe the auto-handoffs.
- `### Thorough flow (deep or Superpowers)` — shows both `deep-brainstorm → team-plan → team-driven-development` and `superpowers:brainstorming → team-plan → team-driven-development` as equivalent thorough-path options. Include an explicit note: specs produced by Superpowers' `brainstorming` feed directly into this plugin's `team-plan` because the spec format is inherited.
- `### Bring your own plan` — if you already have a plan in the task format (example block kept from current README), invoke `team-driven-development` directly. The example Markdown code fence is preserved.
- `### Ad-hoc review` — `solo-review` usage, identical to current content (auto-detection behavior + override options).

The current "This plugin is self-contained" preface line is replaced with: *"Every skill ships with the plugin. Skills interoperate with Superpowers' `brainstorming` and `writing-plans` because the spec/plan formats are shared."*

### Error Handling

Not applicable — documentation only.

### Testing Strategy

Lightweight, manual:

- **Presence checks** — after the edit, run `grep` on both READMEs to confirm: (a) `superpowers:brainstorming` appears in the Skills section and Choosing table, (b) each of the six plugin skills has a `###` heading in Skills, (c) the six `/` invocations appear in Usage, (d) no mention of `superpowers:subagent-driven-development` or "extension of" framing is reintroduced anywhere.
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
