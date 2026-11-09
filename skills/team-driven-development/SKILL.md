---
name: team-driven-development
description: Use when executing implementation plans with a team of specialized subagents — assigns Lead/Worker/Reviewer/Architect roles dynamically, executes in isolated worktrees with Sprint Contracts
---

# Team-Driven Development

Execute implementation plans by orchestrating specialized subagents. The Lead (you) coordinates Workers, Reviewers, and optionally an Architect — each with isolated context and clear responsibilities.

**Why teams:** Role specialization prevents context pollution and enables parallel execution.

## Language Policy

Render user-facing prose (announce, gates, status, errors) in the user's language; explicit user request overrides. Keep literal: commands, paths, `<placeholders>`, backtick-wrapped identifiers (e.g., `PASS`, `DONE`), severity/disposition labels, status markers (📌🔍❓⚠), Markdown structure (headings, table column headers). Default to match recent user input; English if no signal.

Files written to disk (specs, plans, contracts, source code) stay English regardless of conversation language. Apply Token Economy to their contents:

- Omit what the LLM can infer from context or adjacent sections.
- Prefer shortest unambiguous phrasing. Tables/lists beat prose for enumerations.
- No filler transitions ("Next,", "In summary,", "It's important to note that").
- No rationale unless it changes behavior in edge cases.
- Don't restate the same rule twice within one file.

When the user explicitly requests a translation of a generated document, write the English file first, then additionally write a sibling file with an ISO 639-1 language suffix (e.g., `<name>.ja.md` for Japanese, `<name>.fr.md` for French). The English original must always exist; translations are additive, never replacements. Applies to narrative documents (specs, plans, contracts, READMEs); source code stays English (comments included).

## When to Use

You have an implementation plan to execute. No plan → suggest the `quick-brainstorm` skill first. Simple plans automatically trigger Lite Mode suggestion.

## Arguments

- No arguments → auto-triage (Quick Score determines mode)
- `--lite` → skip triage, use Lite Mode. Warn if Quick Score > 1.
- `--full` → skip triage, use Full Mode.

**No plan available:** Suggest `quick-brainstorm` skill. If accepted, invoke with the user's original request as argument. Capture the user's verbatim message before searching for a plan file — this is the `original_request`. Include any additional context (file paths, errors, descriptions) the user provided.

## The Team

| Role | When | Responsibility | Model |
|------|------|----------------|-------|
| **Lead** (you) | Always | Orchestration, dependency analysis, integration, judgment | Session model |
| **Worker** | Every task | Implementation + TDD + self-review in worktree | Per effort score |
| **Reviewer** | Every task | Validate against Sprint Contract | sonnet |
| **Architect** | Design tasks | Design decisions, API shape, data model | opus |
| **Final Reviewer** | After all tasks | Whole-branch review (C-1.5) | opus |

**Summon Architect when:** Task requires choosing between approaches, defines interfaces others depend on, involves data model/API design, or has effort 3+ touching core/shared code. Architect produces a **design brief** (approach, interfaces, constraints).

### Run Ledger

File-backed at `<ws>/ledger.md` (A-0). Source of truth for resume and the Completion Report. Append-only; never rewrite earlier lines. After compaction trust `ledger.md` + `git log` over memory.

First line: `# team-dd ledger — plan: <plan path>`. Then `## Progress` with one event per line:

```
Run: base-branch <name>, run-base <sha7>
Task <N>: dispatched (worktree <path>, branch <branch>, base <sha7>, agent <id>, model <m>)
Task <N>: restarted (worktree missing)
Task <N>: review round <R> <APPROVE|REQUEST_CHANGES> (<Nc>c <NM>M <Nm>m <Nr>r)
Task <N>: fix round <R>/5 (<X> addressed, <Y> open; commits <a7>..<b7>)
Task <N>: minor (deferred): <one-liner>
Task <N>: note: <text>
Task <N>: escalated: <reason>
Task <N>: complete (cherry-pick <sha7>)
Final: review <APPROVE|REQUEST_CHANGES> (<counts>)
Final: fix (commits <a7>..<b7>), re-review <all addressed|<Y> open>
Final: complete
```

Per-task findings: append a `## Task N Review Ledger` section to the same file:

```markdown
## Task N Review Ledger
### Round 0
| # | Source | Severity | File:Line | Finding | Disposition | Detail |
|---|--------|----------|-----------|---------|-------------|--------|
| W-1 | self-review | minor | src/foo.ts:42 | Unused import | fixed | Same commit |
| R-1 | reviewer | major | src/bar.ts:15 | Missing null check | fixed | Commit abc123 |
### Final Status: APPROVE (Round N)
```

**Dispositions:** `fixed`, `deferred` (reason required), `wont-fix` (reason required). Critical/major MUST be `fixed` before the `complete` line.

## Phase 0: Guideline Check

**Trigger:** Runs only when plan creates new files OR modifies 3+ files in a detected domain. Otherwise skip to A-0. Controls *generation* only — existing `guidelines/{domain}.md` files are always incorporated into Sprint Contracts.

**Custom domains:** Any file in project's `guidelines/` is detected and incorporated. Lead uses judgment to match custom domains to tasks.

**Domain Detection:**

| Pattern | Domain |
|---|---|
| `components/`, `pages/`, `layouts/`, `styles/`, `*.css` | frontend |
| `routes/`, `api/`, `controllers/`, `services/`, `models/` | backend |
| `docs/`, `content/`, `*.md` | writing |
| `__tests__/`, `tests/`, `*.test.*`, `*.spec.*` | testing |

Fallback: Lead determines from task content.

**Steps:**
1. Collect file paths → match detection table
2. Check `guidelines/{domain}.md` exists. All exist → skip to A-0
3. **Draft:** Existing code → analyze patterns, generate from `templates/guidelines/{domain}.md`. New project → copy template as-is
4. **User approval:** Present drafts, wait. Changes requested → edit and re-present

Applies to both Lite and Full Mode.

## Phase A-0: Triage

**Announce:** "I'm using team-driven-development to execute this plan."

### Worktree Check

Run: `git rev-parse --git-dir`

If output contains `/worktrees/` → **Worktree Mode**:
- Refuse if `git diff-index --quiet HEAD --` fails → `"Commit or stash changes first."`
- Announce: `"Running in worktree context."`
- If `--branch=<name>` was passed: emit `--branch ignored: running in worktree context, Workers commit to current branch '<current>'`.
- B-2: omit Lead-managed worktree creation; Workers run in current directory.
- Skip B-6.

### Base Branch Resolution

Skip when Worktree Mode is active. Otherwise resolve before Quick Score:

1. **`--branch=<name>` argument** → run `git rev-parse --verify <name>`. Verified: use. Not found: prompt `Branch '<name>' not found. [1] use current '<current>' / [2] specify another / [3] cancel`. Cancel terminates execution.
2. **Plan contains `**Base branch:**` field** → use without prompting.
3. **Otherwise** → prompt `Base Worker worktrees on current branch '<current>'? Reply yes, or specify another branch.` Plain affirmative reuses current; any other reply is treated as a branch name and verified (loop on missing).

Reject branch names containing shell metacharacters (`Invalid branch name: '<value>'`). Hold the resolved value in Lead context for Phase B; do not re-prompt later.

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

## Phase A-0.5: Sprints Gate (F4)

After Triage, before reading the plan (Full Mode only): check that the plan's referenced `docs/team-dd/sprints/<topic>/` directory exists.

- If present → proceed to Phase A.
- If missing → prompt: `docs/team-dd/sprints/<topic>/ not found. Run sprint-master now? [yes/no]`.
  - On `yes` → dispatch the `sprint-master` subagent via the `Agent` tool (`subagent_type: "team-driven-development:sprint-master"`), passing `<spec-path>` and `<plan-path>` in the prompt. The spec path is the `**Spec:**` line in the plan header; the plan path is the current plan. The agent returns here on completion. Proceed to Phase A on success. On failure, abort with the agent's error message and the re-run command `/team-driven-development:sprint-master <spec-path> <plan-path>`.
  - On `no` → abort with `Execution requires Sprint Contract files under docs/team-dd/sprints/<topic>/. Generate them or invoke with --lite to skip Sprint Contract enforcement.`

Lite Mode does not require `docs/team-dd/sprints/<topic>/` and skips the F4 gate.

## Lite Mode

Skip Phases A–C. Lead implements directly.

| Aspect | Full | Lite |
|--------|------|------|
| Implementer | Worker subagent | Lead |
| Isolation | Worktree per task | Current branch |
| Sprint Contract | Per task | None (plan steps) |
| Review | Per-task, profile-based | Single Reviewer, full diff |
| Architect | When needed | None |

**Flow:**
1. Execute tasks sequentially. TDD maintained. Follow existing `guidelines/{domain}.md`.
2. Commit after each task.
3. Dispatch Reviewer on full diff (base SHA → HEAD). Template: `./prompts/reviewer-prompt.md`. **Mandatory — never skip.**
4. APPROVE → brief summary. REQUEST_CHANGES → fix, recommit, re-dispatch (max 2 rounds → escalate).

**Completion Report:**
```markdown
## Completion Report (Lite Mode)
### Tasks Completed: N/N
### Implementation Summary
[What was built — 2–4 sentences. Per-task if N > 2.] Files: f1, f2
### Commit Log
- hash: Task N - description
### Test Results
- `<cmd>`; N passed, 0 failed
### Review
- Verdict: APPROVE | REQUEST_CHANGES → fixed round N
- Findings: Nc, NM, Nm, Nr
### Review Detail (skip if none)
| # | Severity | Finding | Disposition | Detail |
|---|----------|---------|-------------|--------|
### Deferred Items (skip if none)
| # | Severity | Finding | Disposition | Reason |
```

**Worktree Cleanup (Lite):** If stale worktrees from prior sessions exist, offer cleanup per C-4.

## Phase A: Pre-delegate

### A-0: Run Workspace and Resume

`<skill-dir>` = this skill's base directory. Run helpers as `bash <skill-dir>/scripts/<name>` (never rely on exec bits).

1. `bash <skill-dir>/scripts/run-workspace <plan-path>` → prints `<ws>`. Failure or unwritable → abort before Phase B: `Cannot create run workspace: <path>`.
2. `<ws>/ledger.md` missing → create with the identity line and `## Progress`. Present → resume (a ledger owned by another plan never reaches here; `run-workspace` disambiguates via its `plan-path` marker):

| Ledger state for task N | Action |
|---|---|
| `complete` line | Skip. Never re-dispatch or re-cherry-pick |
| `escalated` line, no `complete` | Ask the user how to proceed before touching it |
| `dispatched`, no `complete`, worktree exists | Fresh Worker (worker-prompt.md Fresh Worker template) in that worktree with brief, report, last open findings; continue the fix-round count from the ledger |
| `dispatched`, worktree missing | Append `restarted (worktree missing)`; dispatch from scratch in a new worktree |
| No lines | Normal dispatch |

`Run:` line present → reuse its base branch and run-base. `Final:` lines present → after tasks, resume C-1.5 at the first missing step.

**Workspace files:**

| File | Writer | Purpose |
|---|---|---|
| `ledger.md` | Lead | Run Ledger |
| `task-N-brief.md` | `task-brief` | Task text from plan |
| `task-N-design.md` | Lead | Architect design brief |
| `task-N-report.md` | Worker | Full report; fix rounds appended |
| `task-N-review-rR.md` | Reviewer / Lead | Review (R=0) or re-review (R≥1) |
| `review-<base7>..<head7>.diff` | `review-package` | Review package |
| `final-review.md`, `final-review-r1.md` | Reviewer | Final review, final fix re-review |

Workers and Reviewers write their output file in `<ws>` by absolute path — their only write outside the worktree.

### A-1: Read and Extract
Read plan once. Extract task list, file paths, test commands, criteria for dependency analysis. For each task without a `complete` line: `bash <skill-dir>/scripts/task-brief <plan-path> N` → `<ws>/task-N-brief.md`. Exit 3 → write the task text you extracted to that path yourself and append `Task <N>: note: brief fallback (heading not found)`. Never paste plan text into a dispatch; never make subagents read the whole plan.

### A-2: Dependency Analysis
- **File-based:** B creates file C imports → B before C
- **Type-based:** A defines type B uses → A before B
- **Logical:** A sets up infra B needs → A before B
- **Independent:** Different directories, no shared imports → parallel candidate

### A-5: Read Sprint Contracts

Read `docs/team-dd/sprints/<topic>/common.md` and each `docs/team-dd/sprints/<topic>/task-N.md`. These files are authoritative for Reviewer Profile, Effort Score, Success Criteria, Non-Goals, and Validation. Do not regenerate. Subagents read them by path.

### A-6: Team Composition

Report before Phase B:
```
Team: Lead (orchestration), Workers: N, Reviewer: [profiles], Architect: [tasks if any], Final Reviewer: opus
```

## Phase B: Delegate

**Review is mandatory.** Every task — Full and Lite — dispatches a Reviewer before cherry-pick. No exceptions.

No `Run:` line yet → append `Run: base-branch <name>, run-base <sha7>` (run-base = `git rev-parse <base-branch>`; Worktree Mode: `HEAD`).

Execute in dependency order, skipping `complete` tasks. Parallelize independent tasks (up to 2 Workers, each in own worktree, never sharing files). Cherry-pick in plan order.

**Lead context discipline:** keep only return contracts, verdict lines, and ledger lines you write. Everything else moves as files.

### B-1: Architect Review (design tasks only)

Effort 3+ AND design decisions → dispatch Architect per `./prompts/architect-prompt.md` (paths only). Save the returned design brief verbatim to `<ws>/task-N-design.md`.

### B-2: Dispatch Worker

**Lead creates the worktree before dispatch:**

```bash
git worktree add .claude/worktrees/agent-<task-id> -b worktree-agent-<task-id> <base-branch>
```

`<task-id>` is unique per dispatch (e.g., task index plus a 4-char random suffix to allow parallelism). `<base-branch>` is the value resolved in Phase A-0. On failure (path or branch collision), retry once with a fresh `<task-id>`, then escalate.

Record `BASE` = `git rev-parse <base-branch>` at worktree creation (Worktree Mode: `HEAD` before dispatch; tasks run sequentially there).

Dispatch per `./prompts/worker-prompt.md` Initial Dispatch: worktree block, `## Read First` paths (brief, `common.md`, `task-N.md`, design brief, applicable guidelines), `## Context From Lead`, report path `<ws>/task-N-report.md`. Model per the task-N.md Effort Score. **Do not pass `isolation: "worktree"`** — the Lead-managed worktree replaces it.

When the dispatch returns, append `Task <N>: dispatched (worktree <path>, branch <branch>, base <sha7>, agent <id>, model <m>)`. The agent id is required for fix rounds 1–3.

**Context From Lead rules:**
- One line on where the task fits; interfaces/decisions from earlier tasks the brief cannot know; your resolution of any brief ambiguity
- Reference files: path + one-line description (Worker reads on demand). No file contents
- Budget: ≤ 2 KB. Never paste plan text, contract text, or prior-task summaries

### B-3: Handle Worker Status

| Status | Action |
|--------|--------|
| DONE | Proceed to review |
| DONE_WITH_CONCERNS | Address correctness/scope concerns before review. Note observational concerns, proceed |
| NEEDS_CONTEXT | Provide info, re-dispatch |
| BLOCKED | Context problem → more context. Complexity → capable model. Too large → subtasks. Plan wrong → escalate |

Never force retry without changes.

**On DONE/DONE_WITH_CONCERNS:** confirm `<ws>/task-N-report.md` exists and is non-empty. Missing → send back once to the same Worker; still missing → synthesise Implementation Summary / Files Changed / Test Results from commits + diff into the report file and append `Task <N>: note: report synthesised`. Do not read the full report into context before C-1.

### B-4: Review

1. `bash <skill-dir>/scripts/review-package <plan-path> <BASE> <head-ref>` — head-ref = worktree branch (Worktree Mode: `HEAD`). Prints `wrote <path>: ...`. Never use `HEAD~1`. Exit 3 (empty range) → treat as NEEDS_CONTEXT: tell the Worker to commit.
2. **static (Lead):** read the package → evidence table per Success Criterion from `task-N.md` (MET/NOT_MET + evidence) → verify Non-Goals → L-prefixed findings → write to `<ws>/task-N-review-r0.md` → verdict.
3. **runtime/browser (Reviewer agent):** dispatch per `./prompts/reviewer-prompt.md` (paths only). The Reviewer writes `<ws>/task-N-review-r0.md` and returns the verdict lines.
4. Append `Task <N>: review round 0 <verdict> (<counts>)`. Each minor/recommendation → `Task <N>: minor (deferred): <one-liner>`. Append the `## Task N Review Ledger` section: W-prefixed (report's Self-Review table) and R/L-prefixed findings with dispositions.
5. APPROVE → B-6. REQUEST_CHANGES or any NOT_MET → B-5.

### Verdict Rules

Severity → verdict mapping is defined in `agents/reviewer.md`. The Lead applies the same rules when running a static-profile review.

### B-5: Fix Loop (max 5 rounds)

Minor/recommendation findings never enter the loop (ledgered as deferred in B-4; triaged in C-1.5). Open findings = critical/major + NOT_MET criteria. One round = one fix dispatch + one scoped re-review.

| Round | Implementer | Model |
|---|---|---|
| 1–3 | Resume the original Worker via `SendMessage` (agent id from the `dispatched` line) with open findings verbatim — worker-prompt.md Fix Round template | Original |
| 4–5 | Fresh Worker in the same worktree — worker-prompt.md Fresh Worker template | One tier above original (haiku→sonnet→opus; opus stays opus) |

`SendMessage` unavailable or failing → Fresh Worker on the round's model.

**Every round:**
1. Worker fixes, re-runs covering tests, commits, appends `## Fix Round R` to the report, returns the short contract.
2. Confirm the appended section names covering tests, command, and output. Missing → send back once to the same Worker.
3. `FIX_BASE` = branch head the previous review saw. `bash <skill-dir>/scripts/review-package <plan-path> <FIX_BASE> <head-ref>`.
4. Scoped re-review per `./prompts/re-review-prompt.md` with the findings list → `<ws>/task-N-review-rR.md` (static: Lead does it under agents/reviewer.md `## Mode: re-review`). New critical/major breakage in the fix diff joins the open findings. Out-of-scope observations → `Task <N>: minor (deferred): ...`; they never extend the loop.
5. Append `Task <N>: fix round <R>/5 (...)` and update the task's Review Ledger dispositions.

All addressed → B-6.

**Cap:** round 5 re-review still has open findings → append `Task <N>: escalated: <open finding IDs>` and escalate to the user with the open findings and the report path. Independent tasks may continue meanwhile; dependents wait.

The Lead never fixes findings itself.

### B-6: Cherry-pick to Base Branch

```bash
git checkout <base-branch>
git cherry-pick --no-commit <hash>
git commit -m "<task description>"
```

`<base-branch>` is the value resolved in Phase A-0. **Conflicts:** Lead resolves. Non-trivial → re-dispatch Reviewer (outside the 5-round limit). Cannot resolve → escalate. Record in the task's Review Ledger.

After the commit, append `Task <N>: complete (cherry-pick <sha7>)`. Worktree Mode: no cherry-pick; append `Task <N>: complete (cherry-pick <HEAD sha7>)`.

**Progress:** "Task N/Total complete — [task name]"

## Phase C: Post-delegate

### C-1: Collect Results
Read `<ws>/ledger.md`, each `task-N-report.md`, and review files. Build C-2 from files, not memory.

### C-1.5: Final Whole-Branch Review

Skip when no task reached `complete` in this run.

1. `bash <skill-dir>/scripts/review-package <plan-path> <run-base> <base-branch>` (Worktree Mode: `HEAD`).
2. Dispatch per `./prompts/final-review-prompt.md` (opus) → `<ws>/final-review.md`. Append `Final: review <verdict> (<counts>)`.
3. APPROVE with no `must-fix` triage → append `Final: complete`, go to C-2.
4. Otherwise ONE fix Worker with the complete findings list (never one per finding), model opus, in a new worktree from current `<base-branch>` HEAD (Worktree Mode: current directory). Use the worker-prompt.md Initial Dispatch with `<ws>/final-review.md` as the task brief, `common.md` as the only contract, report `<ws>/final-report.md`.
5. One scoped re-review per `./prompts/re-review-prompt.md` over the fix range → `<ws>/final-review-r1.md`. Cherry-pick as in B-6. Append `Final: fix (commits ...), re-review <result>` then `Final: complete`.
6. No second fix wave. Residual open findings → C-2 `### Final Review Residuals` and surfaced to the user.

### C-2: Completion Report
```markdown
## Completion Report
### Tasks Completed: N/N
| Task | Status | Files | Profile | Rounds | Findings | Tests |
|------|--------|-------|---------|--------|----------|-------|
### Implementation Summary
#### Task N: [name]
[What was built — 2–4 sentences] Files: f1, f2
### Test Results (skip if all clean)
| Task | Command | Passed | Failed | Skipped |
### Review Detail (per task with findings)
| # | Source | Severity | Finding | Disposition | Detail |
### Deferred Items (skip if none)
| # | Task | Severity | Finding | Disposition | Reason |
### Final Review
- Verdict: APPROVE | REQUEST_CHANGES → fixed (commit <sha7>)
- Findings: Nc, NM, Nm, Nr; deferred triaged: N must-fix, N keep-deferred
### Final Review Residuals (skip if none)
| # | Severity | Finding | Reason open |
### Escalated Tasks (skip if none)
| Task | Open findings | Report |
### Summary
- Files changed / Commits / Architect consulted / Avg rounds / Findings / Deferred
### Commit Log
- hash: Task N - description
```

### C-3: Verify
All plan tasks complete. All tests pass on the base branch. No uncommitted changes.

### C-4: Worktree and Workspace Cleanup

Present to user:

```
Run workspace: .team-dd/runs/<slug>/ (ledger, briefs, reports, reviews)
Worktrees from this session:
- .claude/worktrees/agent-XXXX (branch: worktree-agent-XXXX)
Clean up all? [Yes / No / Select]
```

- **Yes** → `git worktree remove` + `git branch -D` for each, `git worktree prune`, then `rm -rf <ws>`.
- **Select** → user picks which to keep.
- **No** → skip. Warn worktrees and workspace persist until manual removal.

Any `escalated` task or final residual → the workspace is kept on **Yes** (say so in the prompt); remove it only if the user selects it explicitly. Skip the prompt only when no session worktrees and no workspace exist.
