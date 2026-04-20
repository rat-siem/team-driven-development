# Team-Driven Development

[日本語](docs/README.ja.md)

A Claude Code plugin that orchestrates implementation plans using a team of specialized subagents with clearly defined roles.

## Architecture

Instead of a single agent doing everything, Team-Driven Development assigns specialized roles to subagents:

```
                 ┌──────────────────────┐
                 │    Lead (you)        │
                 │  Orchestrates, never │
                 │  writes code         │
                 └──────┬───────────────┘
                        │
           ┌────────────┼────────────┐
           ▼            ▼            ▼
     ┌──────────┐ ┌──────────┐ ┌──────────┐
     │ Architect │ │ Worker   │ │ Reviewer │
     │ Design    │ │ Implement│ │ Validate │
     │ decisions │ │ in       │ │ against  │
     │ (when     │ │ isolated │ │ Sprint   │
     │  needed)  │ │ worktree │ │ Contract │
     └──────────┘ └──────────┘ └──────────┘
```

- **Lead** — Analyzes the plan, composes the team, dispatches tasks, integrates results. Never writes implementation code.
- **Worker** — Implements a single task in an isolated git worktree. Follows TDD, self-reviews, reports status.
- **Reviewer** — Validates completed work against a Sprint Contract with evidence-based checklist. Three profiles: `static`, `runtime`, `browser`.
- **Architect** — Summoned only for tasks requiring design decisions. Produces a design brief for the Worker.

## Why Use This

- **The person who writes the code doesn't review it.** Worker and Reviewer are separate agents with separate context. This eliminates self-review bias — the most common failure mode when a single agent implements and validates its own work.
- **Success criteria are locked before work begins.** Sprint Contracts define what "done" means before a single line is code is written. No scope drift, no moving goalposts, no "looks good to me" reviews.
- **Every review finding is tracked to resolution.** The Review Ledger records each finding across fix rounds with a disposition (fixed / deferred / wont-fix). Nothing gets silently dropped.
- **Main branch stays safe.** Workers operate in isolated git worktrees. Changes only reach main after review approval and cherry-pick — a failed task never pollutes the working tree.
- **Token cost scales with task complexity.** Effort Scoring assigns cheaper models (Haiku) to simple tasks and reserves expensive models (Opus) for complex ones. You don't pay Opus prices to rename a variable.
- **Independent tasks run in parallel.** Dynamic dependency analysis identifies tasks that can run simultaneously, dispatching multiple Workers in separate worktrees.

## When NOT to Use This

This plugin adds orchestration overhead. That overhead pays for itself on complex work, but costs more than it saves on simple tasks.

**Use a simpler approach when:**

- **Single-file changes** — A one-file bugfix or config tweak doesn't need a team, a Sprint Contract, or a worktree.
- **Quick prototyping / exploration** — When you're experimenting and expect to throw code away, the contract-and-review cycle slows you down for no benefit.
- **Tasks under ~3 steps** — If the plan has 1-2 straightforward tasks, the triage overhead (even Lite Mode) exceeds the value of role separation.
- **No tests or validation possible** — Sprint Contracts rely on verifiable success criteria. If the task is purely subjective (copy editing, visual polish), the review process has little to verify against.
- **You need tight interactive control** — The team workflow is semi-autonomous by design. If you want to approve every line as it's written, direct implementation is faster.

**Rule of thumb:** If you can describe the entire change in one sentence and it touches ≤ 2 files, skip this plugin.

## Skills

Every skill ships with the plugin and is invokable as `/<skill-name>`. Skills are split into two groups: **Core pipeline** (invoke in sequence for a normal feature) and **Supporting skills** (standalone tools the core pipeline already uses internally; call them directly only in specific situations).

#### Core pipeline

A normal run uses one spec skill, then `team-plan`, then `team-driven-development`.

**Stage 1 — Spec generation (pick one)**

### quick-brainstorm

Lightweight spec generator. Infers what it can from the repo and asks only genuinely ambiguous points. Produces a full-quality spec, then hands off to `team-plan`. Default choice for well-scoped work. Invoked as `/quick-brainstorm <request>`.

### deep-brainstorm

Three-phase spec generator (Distill / Challenge / Harden). Produces an extended spec with Decision Log, Unresolved Items, and Checklist Snapshot. Use when requirements are vague or the decision trail must survive into the artifact. Invoked as `/deep-brainstorm <request>`.

### superpowers:brainstorming *(external, optional)*

The Superpowers project's own brainstorming skill. Specs it produces are compatible with `team-plan` because the spec format is shared. Reach for it when you already work in the Superpowers ecosystem or prefer its dialogue style.

**Stage 2 — Plan generation**

### team-plan

Consumes an approved spec from `docs/team-dd/specs/` and writes a token-optimized plan under `docs/team-dd/plans/`. After plan approval, automatically invokes `sprint-master` to generate Sprint Contract files. Invoked as `/team-plan <spec-path>`.

**Stage 3 — Execution**

### team-driven-development

The orchestration skill. Runs Lead / Worker / Reviewer / Architect roles against the plan + Sprint Contracts, including the Reviewer pass — you do not need `solo-review` as part of this flow. Supports Lite and Full modes (auto-triaged, override with `--lite` / `--full`). If Sprint Contract files are missing it invokes `sprint-master` through the F4 gate automatically. Invoked as `/team-driven-development <plan-path>`.

#### Supporting skills

These are invoked automatically by the core pipeline. Call them directly only in the situations listed below.

### sprint-master

Sole owner of Sprint Contract generation. Reads a spec + plan and writes `docs/team-dd/sprints/<topic>/common.md` and `task-N.md`. Normally invoked by `team-plan` after plan approval, or by `team-driven-development`'s F4 Sprints Gate. Call it directly only when:

- you are bringing your own hand-written plan (skipping `team-plan`) and need Sprint Contract files for it, or
- you edited a plan after contracts were generated and want to regenerate contracts against the updated plan.

Invocation: `/sprint-master <spec-path> <plan-path>`.

### solo-review

Runs the Reviewer agent on its own. Auto-detects review target (staged / uncommitted / branch diff) and adapts criteria (Sprint Contract → plan-derived → generic). The core pipeline already reviews every Worker's output, so `solo-review` is **not** part of the standard flow. Call it directly when:

- you want an extra review pass from a different angle (e.g., force `--profile runtime` or `--profile browser` after a `static` review),
- you re-review code that `team-driven-development` already approved, for a fresh concern (security, performance, refactor readiness),
- you want to review a specific commit range or path (`/solo-review HEAD~3..HEAD`, `/solo-review src/api/`),
- you are reviewing code written outside the team pipeline (hand-written changes, external contributions), or
- you want to review against a specific Sprint Contract on demand (`--contract <path>`).

Invocation: `/solo-review [range|path] [--profile ...] [--contract ...]`.

#### Cross-cutting capabilities

Engine-level features that aren't skills but show up across the pipeline:

- **Effort Scoring** — Automatic Worker model selection (cheap / standard / capable) based on task complexity.
- **Worktree isolation** — Workers run in isolated git worktrees; changes reach main only after review approval.
- **Worktree-aware execution** — Detects when invoked from inside a worktree and adapts (no sub-worktrees, no cherry-pick).
- **Review Ledger** — Every review finding tracked across rounds with disposition (fixed / deferred / wont-fix) and surfaced in the completion report.
- **Domain Guidelines** — Auto-detects missing domain guidelines, drafts from existing code, and embeds approved guidelines into Sprint Contracts.
- **Sprint Contract QA** — Contracts validated before Worker dispatch (verifiable criteria, non-goals, profile match).
- **Dynamic dependency analysis** — Execution order derived from plan content at runtime.
- **Parallel execution** — Independent tasks dispatched simultaneously across Workers.
- **Three-tier review** — `static` (Lead reads diff), `runtime` (agent runs tests), `browser` (agent + UI verification).
- **Adaptive process selection** — Lite Mode for simple plans, Full Mode for complex plans, overridable with `--lite` / `--full`.

## Choosing a Skill

**Entry-point decision**

```
What do you have?
├── A rough idea, clear scope               → /quick-brainstorm
├── A vague or high-stakes requirement      → /deep-brainstorm
├── A spec already (yours or Superpowers')  → /team-plan <spec>
└── A plan already (+ Sprint Contracts)     → /team-driven-development <plan>
```

**Core pipeline — the skills you pick between for normal work**

| When you... | Use | Output | Next |
|---|---|---|---|
| Have a clear request, want a spec fast | `quick-brainstorm` | spec | `team-plan` |
| Have a vague/high-stakes requirement | `deep-brainstorm` | extended spec with Decision Log | `team-plan` |
| Already live in the Superpowers ecosystem | `superpowers:brainstorming` | Superpowers-format spec | `team-plan` (compatible) |
| Have an approved spec | `team-plan` | plan + Sprint Contracts (via `sprint-master`) | `team-driven-development` |
| Have a plan + Sprint Contracts | `team-driven-development` | implemented, reviewed code | — |

If you are unsure between `quick-brainstorm` and `deep-brainstorm`, default to `quick-brainstorm` — it will surface ambiguities that warrant escalating. If you are unsure between this plugin's brainstorming skills and `superpowers:brainstorming`, either works; choose by familiarity.

**Supporting skills — reach for them only in these situations**

| Situation | Use | Why not the core pipeline? |
|---|---|---|
| You hand-wrote a plan and need Sprint Contracts | `sprint-master` | `team-plan` generates contracts automatically from its own plans; run `sprint-master` yourself only when skipping `team-plan`. |
| You edited the plan after contracts were generated | `sprint-master` | Regenerate contracts against the updated plan. |
| You want a review from a different angle after `team-driven-development` approved | `solo-review --profile <runtime\|browser>` | The core pipeline reviews each task against its contract; `solo-review` adds a fresh-angle pass on top. |
| You are reviewing code not produced by the pipeline (hand-written, external PR) | `solo-review` | The core pipeline only reviews Worker output. |
| You want to review a specific range or path on demand | `solo-review HEAD~3..HEAD` / `solo-review src/api/` | Targeted ad-hoc review. |
| You want to force a specific Sprint Contract against current changes | `solo-review --contract <path>` | Run the Reviewer with an explicit contract outside the team flow. |

## Workflow

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

Specs live in `docs/team-dd/specs/`, plans in `docs/team-dd/plans/`, and Sprint Contracts in `docs/team-dd/sprints/<topic>/`. Each stage has a single owner: `quick-brainstorm` / `deep-brainstorm` own specs, `team-plan` owns plans, `sprint-master` owns Sprint Contracts, and `team-driven-development` owns execution. Reviewer runs inside `team-driven-development` — `solo-review` is not a pipeline stage.

## Usage

Every skill ships with the plugin. Skills interoperate with Superpowers' `brainstorming` and `writing-plans` because the spec/plan formats are shared.

### Core pipeline

#### Standard flow (quick)

```
/quick-brainstorm <request>   # produces spec
→ approve spec
→ team-plan runs              # produces plan; then auto-invokes sprint-master
→ approve plan
→ team-driven-development runs  # executes plan, Reviewer runs inside
```

`quick-brainstorm` hands the approved spec to `team-plan`. `team-plan` invokes `sprint-master` automatically to generate Sprint Contract files. `team-driven-development` dispatches Workers and runs the Reviewer against each Sprint Contract — no separate review step is needed.

#### Thorough flow (deep or Superpowers)

```
/deep-brainstorm <request> → team-plan → team-driven-development
# or
superpowers:brainstorming → team-plan → team-driven-development
```

Use `deep-brainstorm` for vague or high-stakes requirements that benefit from multiple approach comparisons and a preserved Decision Log. Specs produced by Superpowers' `brainstorming` feed directly into this plugin's `team-plan` because the spec format is shared.

#### Bring your own plan

If you already have a plan in the team-plan task format, invoke `team-driven-development` directly:

````markdown
### Task 1: [Name]

**Files:**
- Create: `src/models/user.py`
- Test: `tests/test_user.py`

- [ ] **Step 1: Write failing test**
```python
def test_user_creation():
    user = User("Alice", "alice@example.com")
    assert user.name == "Alice"
```

- [ ] **Step 2: Implement**
...
````

If Sprint Contract files are missing, `team-driven-development`'s F4 Sprints Gate will invoke `sprint-master` for you; alternatively, run `sprint-master` yourself first.

### Supporting skills (manual)

#### Regenerating Sprint Contracts (`sprint-master`)

Call `sprint-master` directly in two situations: (1) you hand-wrote a plan and skipped `team-plan`; (2) you edited a plan after contracts were generated and want them regenerated.

```
/sprint-master <spec-path> <plan-path>
```

#### Ad-hoc review (`solo-review`)

The core pipeline reviews every Worker's output, so `solo-review` is for situations the pipeline doesn't cover: extra review angle, code outside the pipeline, targeted range or path, forced profile, or explicit contract.

```
/solo-review                                      # current changes, auto-detect
/solo-review HEAD~3..HEAD                         # specific commit range
/solo-review src/api/                             # specific path
/solo-review --profile runtime                    # force runtime validation
/solo-review --contract path/to/contract.md       # use a specific Sprint Contract
```

`solo-review` auto-detects review criteria:

- **Has Sprint Contract?** → Contract-based review (identical to `team-driven-development`)
- **Has plan file?** → Derives criteria from matching plan tasks
- **Neither?** → Generic code review (security, correctness, test coverage)

## How It Works

### Phase 0: Guideline Check
1. Detect which domains the plan touches (directory-pattern matching with Lead fallback)
2. Check if `guidelines/{domain}.md` exists for each domain
3. If missing and the plan creates new files or modifies 3+ files in that domain → generate a draft from existing code or templates
4. User approves or edits the draft → guidelines are used in Sprint Contracts going forward

### Phase A-0: Triage
0. **Worktree Check** — Detect if running inside a git worktree. If so, activate Worktree Mode: Workers commit directly to the current branch (no sub-worktrees, no cherry-pick). Requires a clean working tree.
1. Read the plan and calculate a Quick Score (task count, file count, domain spread, design keywords)
2. Quick Score ≤ 1 → propose **Lite Mode** to the user
3. User accepts → Lead implements directly with a single Reviewer pass at the end
4. User declines or Quick Score > 1 → proceed to Phase A-0.5 (Full Mode)

### Phase A-0.5: Sprints Gate (F4)
1. Check that `docs/team-dd/sprints/<topic>/` exists for the plan
2. If present → proceed to Phase A
3. If missing → prompt: `docs/team-dd/sprints/<topic>/ not found. Run sprint-master now? [yes/no]`
4. On `yes` → invoke `/team-driven-development:sprint-master <spec-path> <plan-path>`, then proceed to Phase A
5. On `no` → abort with guidance to generate Sprint Contract files or use `--lite`
6. Lite Mode skips this gate

### Phase A: Pre-delegate (Full Mode)
1. Read and extract all tasks from the plan
2. Read `docs/team-dd/sprints/<topic>/common.md` and each `task-N.md` (authoritative; do not regenerate)
3. Analyze dependencies dynamically
4. Determine team composition

### Phase B: Delegate (per task)
1. Dispatch Architect for design brief (if needed)
2. Dispatch Worker in isolated worktree
3. Review against Sprint Contract with **evidence table** (every criterion gets MET/NOT_MET + evidence)
4. Fix loop (max 3 rounds) if REQUEST_CHANGES — all findings tracked in **Review Ledger** with dispositions
5. Cherry-pick to main on APPROVE (conflict resolution flow if needed)

### Phase C: Post-delegate
1. Collect all results
2. Generate **completion report** with implementation summary (what was built per task), test results, per-task review detail (findings, dispositions), and deferred items with reasons
3. Verify all tasks complete

## Sprint Contract Example

```markdown
## Sprint Contract: Task 2 - User API Endpoints

### Success Criteria
- [ ] GET /api/users returns 200 with JSON array
- [ ] POST /api/users creates user and returns 201
- [ ] Tests pass: `pytest tests/test_api.py -v`

### Non-Goals
- Do not implement authentication (Task 4)
- Do not add pagination (future work)

### Reviewer Profile: runtime

### Runtime Validation
- `pytest tests/test_api.py -v` — expected: PASS
- `mypy src/api/` — expected: PASS
```

## Effort Scoring

Tasks are scored 0-5 for complexity, which determines the Worker model:

| Score | Model | Task Type |
|-------|-------|-----------|
| 0-1 | haiku (cheap) | Mechanical: clear spec, 1-2 files |
| 2 | sonnet (standard) | Integration: multi-file, judgment needed |
| 3+ | opus (capable) | Architecture: complex, cross-cutting |

Scoring factors: file count, directory risk, keywords, cross-cutting concerns, new subsystems.

## Design Note: Intentional YAGNI Violation on Deferral

When a user defers a decision during quick-brainstorm's clarification phase ("either is fine", "I'll leave it to you"), the skill deliberately violates the YAGNI principle. Instead of choosing the minimal/conservative option, it selects the most comprehensive approach that fully satisfies all potential requirements — even if this results in broader scope than the minimal interpretation.

This is an explicit, intentional design choice. The rationale: when a user delegates a decision, they are trusting the agent to produce the strongest possible design. A narrow plan that leaves gaps is worse than a slightly broader plan that covers edge cases. The deferred decision and reasoning are recorded in the spec for transparency.

This rule applies only to deferred decisions. When the user specifies a preference, that preference is always respected — YAGNI applies normally.

## Installation

### From Claude Code (recommended)

Use the `/plugin` slash command inside a Claude Code session:

```
/plugin marketplace add https://github.com/rat-siem/team-driven-development
/plugin install team-driven-development@team-driven-dev
```

### From Terminal

```bash
# 1. Register marketplace
claude plugin marketplace add https://github.com/rat-siem/team-driven-development

# 2. Install
claude plugin install team-driven-development@team-driven-dev
```

### From Local Path (for development)

```bash
claude plugin add /path/to/team-driven-development
```

## Updating

To update to the latest version:

```
/plugin update team-driven-development
```

Or from the terminal:

```bash
claude plugin update team-driven-development
```

## Requirements

- Claude Code with subagent support
- Git (for worktree isolation)
- No Node.js or other runtime dependencies

## License

MIT
