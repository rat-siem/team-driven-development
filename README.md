# Team-Driven Development

[日本語](docs/README.ja.md)

A Claude Code plugin that orchestrates implementation plans using a team of specialized subagents with clearly defined roles.

## What It Does

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

## Key Features

- **Quick Brainstorm** — Lightweight spec + plan generation with minimal dialogue. Infers what it can from context, asks only what's genuinely ambiguous, and outputs full-quality documents. Hands off via `quick-brainstorm → team-plan → team-driven-development` (`team-plan` invokes `sprint-master` internally to generate Sprint Contract files). Use `/quick-brainstorm` or let team-driven-development suggest it when no plan exists.
- **Deep Brainstorm** — Rigorous three-phase variant (Distill / Challenge / Harden) for vague or high-stakes requirements. Produces an extended spec with Decision Log, Unresolved Items, and Checklist Snapshot. Use `/deep-brainstorm` when decision reasoning must survive into the spec.
- **Team Plan** — In-plugin implementation-plan writer. Consumes an approved spec at `docs/team-dd/specs/` and emits a token-optimized plan under `docs/team-dd/plans/`, then invokes `sprint-master` to generate Sprint Contract files. Invoke as `/team-plan <spec-path>`.
- **Sprint Master** — Sole owner of Sprint Contract generation. Reads a spec + plan and writes `sprints/<topic>/common.md` and `task-N.md`. Invoked by `team-plan` after plan generation, directly via `/sprint-master <spec-path> <plan-path>`, or via the F4 Sprints Gate in team-driven-development.
- **Solo Review** — Standalone code review using the Reviewer agent. Auto-detects review target (staged, uncommitted, or branch diff), adapts criteria (Sprint Contract → plan-derived → generic), and produces structured verdicts. Use `/solo-review` for on-demand review without the full team workflow.
- **Adaptive process selection** — Simple plans trigger a Lite Mode suggestion; complex plans use the full team process. Use `--lite` or `--full` to skip triage and select mode directly.
- **Dynamic team composition** — Roles assigned per task based on complexity and type
- **Sprint Contracts** — Success criteria, non-goals, and review profile defined before work begins
- **Effort Scoring** — Automatic model selection (cheap/standard/capable) based on task complexity
- **Worktree isolation** — Workers operate in isolated git worktrees; changes reach main only after approval
- **Worktree-aware execution** — Detects when invoked from inside a git worktree and adapts automatically: Workers commit directly to the current branch, no sub-worktrees are created, cherry-pick is skipped
- **Dynamic dependency analysis** — Execution order determined from plan content (file paths, imports, logical dependencies)
- **Parallel execution** — Independent tasks run simultaneously with separate Workers
- **Three-tier review** — `static` (Lead reads diff), `runtime` (agent runs tests), `browser` (agent + UI verification)
- **Review Ledger** — Every finding tracked with disposition (fixed/deferred/wont-fix) across review rounds, surfaced in the completion report
- **Sprint Contract QA** — Contracts validated before Worker dispatch (verifiable criteria, non-goals, profile match)
- **Domain Guidelines** — Auto-detects when a project lacks domain-specific guidelines (frontend, backend, writing, testing), generates drafts from existing code, and integrates approved guidelines into Sprint Contracts. Workers follow them as constraints; Reviewers check compliance.

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
1. Check that `sprints/<topic>/` exists for the plan
2. If present → proceed to Phase A
3. If missing → prompt: `sprints/<topic>/ not found. Run sprint-master now? [yes/no]`
4. On `yes` → invoke `/team-driven-development:sprint-master <spec-path> <plan-path>`, then proceed to Phase A
5. On `no` → abort with guidance to generate Sprint Contract files or use `--lite`
6. Lite Mode skips this gate

### Phase A: Pre-delegate (Full Mode)
1. Read and extract all tasks from the plan
2. Read `sprints/<topic>/common.md` and each `task-N.md` (authoritative; do not regenerate)
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

## Usage

This plugin is self-contained — all planning, implementation, and review skills ship with it.

### With Quick Brainstorm (self-contained)

```
/quick-brainstorm <task description> → team-plan → team-driven-development
```

The `quick-brainstorm` skill generates a spec with minimal dialogue. When the spec is approved, it hands off to `team-plan`, which produces the implementation plan and invokes `sprint-master` internally to generate Sprint Contract files. When the plan is ready, the flow offers to hand off to team-driven-development for execution. If team-driven-development is invoked without a plan, it will suggest quick-brainstorm automatically.

### Solo Review (standalone)

```
/solo-review
```

Review your current changes without running the full team workflow. The skill auto-detects what to review and which criteria to use:

- **Has Sprint Contract?** → Contract-based review (identical to team-driven-development)
- **Has plan file?** → Derives criteria from matching plan tasks
- **Neither?** → Generic code review (security, correctness, test coverage)

Override options:
```
/solo-review HEAD~3..HEAD              # specific commit range
/solo-review src/api/                  # specific path
/solo-review --profile runtime         # force runtime validation
/solo-review --contract path/to/contract.md  # use specific Sprint Contract
```

### With Deep Brainstorm (thorough)

```
deep-brainstorm → team-plan → team-driven-development
```

For vague or high-stakes requirements that need deep exploration — multiple approach comparisons, section-by-section design approval, Decision Log preservation — use `deep-brainstorm`. It drives Distill / Challenge / Harden phases and produces an extended spec. The approved spec flows into `team-plan`, which generates the implementation plan and invokes `sprint-master` to produce Sprint Contract files. Execute the plan with Team-Driven Development for complex work that benefits from role specialization.

### Standalone

Write a plan in the team-plan task format:

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

Then invoke the skill and point it at your plan.

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

## Requirements

- Claude Code with subagent support
- Git (for worktree isolation)
- No Node.js or other runtime dependencies

## License

MIT
