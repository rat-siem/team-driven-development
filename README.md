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

## Key Features

- **Quick Plan** — Lightweight spec + plan generation with minimal dialogue. Infers what it can from context, asks only what's genuinely ambiguous, and outputs full-quality documents. Use `/quick-plan` or let team-driven-development suggest it when no plan exists.
- **Solo Review** — Standalone code review using the Reviewer agent. Auto-detects review target (staged, uncommitted, or branch diff), adapts criteria (Sprint Contract → plan-derived → generic), and produces structured verdicts. Use `/solo-review` for on-demand review without the full team workflow.
- **Adaptive process selection** — Simple plans trigger a Lite Mode suggestion; complex plans use the full team process. Use `--lite` or `--full` to skip triage and select mode directly.
- **Dynamic team composition** — Roles assigned per task based on complexity and type
- **Sprint Contracts** — Success criteria, non-goals, and review profile defined before work begins
- **Effort Scoring** — Automatic model selection (cheap/standard/capable) based on task complexity
- **Worktree isolation** — Workers operate in isolated git worktrees; changes reach main only after approval
- **Dynamic dependency analysis** — Execution order determined from plan content (file paths, imports, logical dependencies)
- **Parallel execution** — Independent tasks run simultaneously with separate Workers
- **Three-tier review** — `static` (Lead reads diff), `runtime` (agent runs tests), `browser` (agent + UI verification)
- **Review Ledger** — Every finding tracked with disposition (fixed/deferred/wont-fix) across review rounds, surfaced in the completion report
- **Sprint Contract QA** — Contracts validated before Worker dispatch (verifiable criteria, non-goals, profile match)

## How It Works

### Phase A-0: Triage
1. Read the plan and calculate a Quick Score (task count, file count, domain spread, design keywords)
2. Quick Score ≤ 1 → propose **Lite Mode** to the user
3. User accepts → Lead implements directly with a single Reviewer pass at the end
4. User declines or Quick Score > 1 → proceed to Full Mode (Phase A)

### Phase A: Pre-delegate (Full Mode)
1. Read and extract all tasks from the plan
2. Analyze dependencies dynamically
3. Score effort per task
4. Select reviewer profile per task
5. Generate Sprint Contracts
6. **Contract QA** — Validate each contract (verifiable criteria, test commands, non-goals, profile match, dependency preconditions)
7. Determine team composition

### Phase B: Delegate (per task)
1. Dispatch Architect for design brief (if needed)
2. Dispatch Worker in isolated worktree
3. Review against Sprint Contract with **evidence table** (every criterion gets MET/NOT_MET + evidence)
4. Fix loop (max 3 rounds) if REQUEST_CHANGES — all findings tracked in **Review Ledger** with dispositions
5. Cherry-pick to main on APPROVE (conflict resolution flow if needed)

### Phase C: Post-delegate
1. Collect all results
2. Generate **completion report** with per-task review detail (findings, dispositions, deferred items with reasons)
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

This plugin works best with [Superpowers](https://github.com/obra/superpowers) but can be used standalone.

### With Quick Plan (self-contained)

```
/quick-plan <task description> → team-driven-development
```

The `quick-plan` skill generates a spec and plan with minimal dialogue — no superpowers dependency needed. When the plan is ready, it offers to hand off directly to team-driven-development for execution. If team-driven-development is invoked without a plan, it will suggest quick-plan automatically.

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

### With Superpowers (thorough)

```
brainstorming → writing-plans → team-driven-development
```

For tasks that need deep exploration — multiple approach comparisons, section-by-section design approval, visual mockups — use the full Superpowers flow. The `writing-plans` skill produces a plan. When choosing an execution method, select Team-Driven Development for complex plans that benefit from role specialization.

### Standalone

Write a plan in the Superpowers task format:

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

When a user defers a decision during quick-plan's clarification phase ("either is fine", "I'll leave it to you"), the skill deliberately violates the YAGNI principle. Instead of choosing the minimal/conservative option, it selects the most comprehensive approach that fully satisfies all potential requirements — even if this results in broader scope than the minimal interpretation.

This is an explicit, intentional design choice. The rationale: when a user delegates a decision, they are trusting the agent to produce the strongest possible design. A narrow plan that leaves gaps is worse than a slightly broader plan that covers edge cases. The deferred decision and reasoning are recorded in the spec for transparency.

This rule applies only to deferred decisions. When the user specifies a preference, that preference is always respected — YAGNI applies normally.

## Requirements

- Claude Code with subagent support
- Git (for worktree isolation)
- No Node.js or other runtime dependencies

## License

MIT
