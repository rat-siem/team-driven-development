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
- **Reviewer** — Validates completed work against a Sprint Contract. Three profiles: `static`, `runtime`, `browser`.
- **Architect** — Summoned only for tasks requiring design decisions. Produces a design brief for the Worker.

## Key Features

- **Dynamic team composition** — Roles assigned per task based on complexity and type
- **Sprint Contracts** — Success criteria, non-goals, and review profile defined before work begins
- **Effort Scoring** — Automatic model selection (cheap/standard/capable) based on task complexity
- **Worktree isolation** — Workers operate in isolated git worktrees; changes reach main only after approval
- **Dynamic dependency analysis** — Execution order determined from plan content (file paths, imports, logical dependencies)
- **Parallel execution** — Independent tasks run simultaneously with separate Workers
- **Three-tier review** — `static` (Lead reads diff), `runtime` (agent runs tests), `browser` (agent + UI verification)

## How It Works

### Phase A: Pre-delegate
1. Read and extract all tasks from the plan
2. Analyze dependencies dynamically
3. Score effort per task
4. Select reviewer profile per task
5. Generate Sprint Contracts
6. Determine team composition

### Phase B: Delegate (per task)
1. Dispatch Architect for design brief (if needed)
2. Dispatch Worker in isolated worktree
3. Review against Sprint Contract
4. Fix loop (max 3 rounds) if REQUEST_CHANGES
5. Cherry-pick to main on APPROVE

### Phase C: Post-delegate
1. Collect all results
2. Generate completion report
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

### With Superpowers (recommended)

```
brainstorming → writing-plans → team-driven-development
```

The `writing-plans` skill produces a plan. When choosing an execution method, select Team-Driven Development for complex plans that benefit from role specialization.

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

## Requirements

- Claude Code with subagent support
- Git (for worktree isolation)
- No Node.js or other runtime dependencies

## License

MIT
