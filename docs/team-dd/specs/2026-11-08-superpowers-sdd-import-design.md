# Superpowers SDD Import Design

**Base branch:** develop

## Overview

Port five mechanisms from superpowers 7.0.0 `subagent-driven-development` into team-driven-development Full Mode: a file-backed ledger with resume, file-based artifact handoff, a final whole-branch review, a 5-round fix loop with Worker resume and model escalation, and a no-subagents contract for Workers. team-dd differentiators (parallel Workers, per-task worktree + cherry-pick, Sprint Contracts, reviewer profiles, Architect) stay intact.

## Motivation

- Review Ledger lives only in Lead context (`SKILL.md` "Managed in Lead's context (not filesystem)"); compaction loses progress and can trigger re-execution of completed tasks.
- Task text, Sprint Contract, guidelines, and context are pasted into Worker prompts, and Workers return full reports; both stay resident in Lead context for the whole session.
- No review covers the integrated result; cross-task defects are caught only by C-3 tests.
- Fix loop caps at 3 rounds then escalates to user; no Worker resume, no model escalation, re-review re-examines the whole task.
- Workers are not forbidden from spawning their own reviewers, duplicating the Lead-dispatched review.

## Scope

| In | Out |
|---|---|
| Full Mode Phases A–C | Lite Mode (unchanged) |
| Worker / Reviewer / Architect prompts, `agents/worker.md`, `agents/reviewer.md` | sprint-master, team-plan, brainstorm skills |
| New bash helpers under `skills/team-driven-development/scripts/` | Autonomous rulings (superpowers "Rulings, not stalls") — cap and residuals still escalate to user |
| README (EN + JA) workflow description | Batching same-shape tasks, pre-flight scan, Effort Scoring changes |

## Design

### Run Workspace

One git-ignored directory per plan holds all run artifacts.

- Path: `<repo-root>/.team-dd/runs/<plan-slug>/` where `<repo-root>` = `git rev-parse --show-toplevel` of the Lead's cwd, `<plan-slug>` = plan basename without `.md`.
- `.team-dd/.gitignore` containing `*` is created only if absent (create-only, never overwritten).
- Ownership marker `plan-path` (repo-relative plan path). Marker naming a different plan → disambiguate slug with parent dir name, then numeric suffix (same algorithm as superpowers `sdd-workspace`).
- Contents:

| File | Writer | Purpose |
|---|---|---|
| `ledger.md` | Lead | Progress + Review Ledger (see below) |
| `task-N-brief.md` | `task-brief` script | Task text extracted from plan |
| `task-N-design.md` | Lead (Architect output) | Design brief, only for Architect tasks |
| `task-N-report.md` | Worker | Full Worker report; fix reports appended |
| `task-N-review-rR.md` | Reviewer / Lead | Review or re-review report for round R (R=0 initial) |
| `review-<base7>..<head7>.diff` | `review-package` script | Review package |
| `final-review.md` | Final Reviewer | Final whole-branch review |

Worker and Reviewer write to these paths via absolute path; this is the single allowed exception to "do not modify files outside the worktree".

### Helper Scripts

Location: `skills/team-driven-development/scripts/`. Invoked by the Lead as `bash <skill-dir>/scripts/<name> ...` (always via `bash`, exec bits not assumed). All use `set -euo pipefail`, print the written path on stdout, errors on stderr.

| Script | Usage | Behavior | Exit codes |
|---|---|---|---|
| `run-workspace` | `run-workspace PLAN_FILE` | Resolve/create workspace dir per above; print absolute path | 0 ok, 2 usage/missing plan |
| `task-brief` | `task-brief PLAN_FILE N [OUTFILE]` | Extract the `#+ Task N` section (heading through next `#+ Task` heading, ignoring headings inside code fences) to `<ws>/task-N-brief.md` | 0, 2 usage, 3 task not found |
| `review-package` | `review-package PLAN_FILE BASE HEAD [OUTFILE]` | Write commit list, `--stat`, `diff -U10` for `BASE..HEAD` to `<ws>/review-<base7>..<head7>.diff`; print path + commit count + bytes | 0, 2 usage/bad ref, 3 HEAD not descendant of BASE or empty range |

Adapted from superpowers (MIT). Each script header carries: `# Adapted from obra/superpowers (MIT License, Copyright (c) 2025 Jesse Vincent).`

### Ledger File

`<ws>/ledger.md` replaces the in-context Review Ledger. First line is identity: `# team-dd ledger — plan: <plan path>`. Lead appends; never rewrites earlier lines.

Line grammar (one event per line under `## Progress`):

```
Run: base-branch <name>, run-base <sha7>
Task <N>: dispatched (worktree <path>, branch <branch>, base <sha7>, agent <id>, model <m>)
Task <N>: review round <R> <APPROVE|REQUEST_CHANGES> (<Nc>c <NM>M <Nm>m <Nr>r)
Task <N>: fix round <R>/5 (<X> addressed, <Y> open; commits <a7>..<b7>)
Task <N>: minor (deferred): <one-liner>
Task <N>: escalated: <reason>
Task <N>: complete (cherry-pick <sha7>)
Final: review <APPROVE|REQUEST_CHANGES> (<counts>)
Final: fix (commits <a7>..<b7>), re-review <all addressed|<Y> open>
Final: complete
```

Per-task finding/disposition tables (existing Review Ledger format: W-/R-/L-prefixed IDs, `fixed|deferred|wont-fix`) go under `## Task <N> Review Ledger` sections appended to the same file. Critical/major MUST be `fixed` before `complete` (unchanged rule).

`run-base` = base-branch HEAD SHA recorded once at Phase B start; final review range starts here.

Completion Report (C-2) is built by reading `ledger.md`, `task-N-report.md`, and review files — not from memory.

### Resume

At Phase A start (after Sprints Gate), Lead runs `run-workspace` and reads `ledger.md` if present:

| Ledger state for task N | Action |
|---|---|
| `complete` line | Skip; never re-dispatch or re-cherry-pick |
| `dispatched` but no `complete`, worktree exists | Resume in that worktree with a fresh Worker carrying brief + report + last open findings; continue fix-round count from ledger |
| `dispatched`, worktree missing | Re-dispatch from scratch (new worktree); ledger `Task <N>: restarted (worktree missing)` |
| No lines | Normal dispatch |
| `Final:` lines present | Resume final review stage at the next missing step |

Ledger whose identity line names another plan → leave it, start fresh in a disambiguated workspace (handled by `run-workspace` marker). After compaction, trust `ledger.md` + `git log` over memory. `Run:` line on resume is reused, not rewritten.

### File-Based Handoff

**Worker dispatch (`prompts/worker-prompt.md`)** contains only:

1. `## Worktree` block (unchanged).
2. `## Read First` — absolute paths: task brief, `docs/team-dd/sprints/<topic>/common.md`, `docs/team-dd/sprints/<topic>/task-N.md`, design brief (if any), applicable `guidelines/<domain>.md`. Worker reads them before starting; brief values are used verbatim.
3. `## Context From Lead` — one line on where the task fits; interfaces/decisions from earlier tasks the brief cannot know; Lead's resolution of any brief ambiguity; reference file paths with one-line descriptions (≤ 2 KB total, same budget as before; no full file contents).
4. `## Report` — report-file path and short-return contract.

Never paste plan text, contract text, or accumulated prior-task summaries.

**Worker return contract (final message):**

```
Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
Commits: <sha7> <subject> (one per line)
Tests: <one line, e.g. "14/14 passing">
Report: <report-file path>
Concerns: <only for DONE_WITH_CONCERNS>
```

NEEDS_CONTEXT / BLOCKED put specifics in the final message itself. Full report (Implementation Summary, Files Changed, Test Results with command + output, Self-Review Findings table) goes in `task-N-report.md`; fix rounds append `## Fix Round R` sections (findings addressed, covering tests, command, output).

**Review package:** Lead records `BASE` = worktree base SHA before dispatch (in `dispatched` line). On DONE, Lead runs `review-package PLAN BASE <worktree-branch>`; never `HEAD~1`. Worktree Mode: `BASE` = current `HEAD` before dispatch, head ref = `HEAD`; tasks run sequentially there.

**Reviewer dispatch (`prompts/reviewer-prompt.md`)** passes paths only: brief, `common.md`, `task-N.md`, report file, review package, output path `task-N-review-r0.md`, profile. Reviewer writes the full review (existing report format) to the output path and returns: `Verdict`, counts, output path. Reviewer does not re-run tests the report already evidences, except validation commands mandated by the Sprint Contract for its profile (runtime/browser validation is the profile's purpose).

**static profile:** Lead reads the review package file (not raw `git diff`) and writes its evidence table to `task-N-review-rR.md`.

**Architect:** dispatch passes brief + contract paths; Architect output is saved by Lead to `task-N-design.md` and passed as a path to the Worker.

Lead keeps in context only: return contracts, verdict lines, and ledger lines it writes.

### Fix Loop (replaces B-5)

Trigger: REQUEST_CHANGES (any critical/major) or a NOT_MET criterion. Minor/recommendation findings never enter the loop; each is ledgered as `Task <N>: minor (deferred): ...` and fed to the final review.

Max 5 rounds per task. One round = one fix dispatch + one scoped re-review.

| Round | Implementer | Model |
|---|---|---|
| 1–3 | Resume original Worker via `SendMessage` (agent id from `dispatched` line) with open findings verbatim | Same as original |
| 4–5 | Fresh Worker in the same worktree with brief path, report path, open findings, framing: "A prior Worker attempted this task <R-1> times; you own it now. Read the report file for what was tried." | One tier above original (haiku→sonnet→opus; opus stays opus) |

Resume fallback: `SendMessage` unavailable or fails → fresh Worker on the round's model with brief + report + findings.

Every round: Worker fixes, re-runs covering tests, appends `## Fix Round R` to the report, returns the short contract. Lead verifies the appended section names tests, command, and output before re-review; missing → send back once to the same Worker.

**Scoped re-review:** `FIX_BASE` = branch head the previous review saw. Lead runs `review-package PLAN FIX_BASE HEAD`, dispatches the reviewer in re-review mode (new `prompts/re-review-prompt.md`) with findings list, brief, report, diff path, output `task-N-review-rR.md`. Re-reviewer:
- verdicts each finding `ADDRESSED | NOT ADDRESSED` with file:line evidence;
- lists new critical/major breakage in the fix diff only (joins open findings);
- lists out-of-scope observations (Lead ledgers as deferred minors; never extends the loop).

static profile: Lead performs the scoped re-review itself, same rules.

After each round: append `fix round` ledger line and update the task's Review Ledger dispositions.

**Cap:** round 5 re-review still has open findings → ledger `escalated` and escalate to user with the open findings and report path (team-dd keeps user escalation; no autonomous adjudication). Other independent tasks may continue in parallel while awaiting the user.

Lead never fixes findings itself (unchanged role: Lead does not write code). Cherry-pick conflicts keep current handling (outside the 5-round limit).

### Final Whole-Branch Review (new Phase C-1.5, after all tasks cherry-picked, before Completion Report)

Skipped when every task was escalated/skipped or zero tasks were cherry-picked in this run.

1. `review-package PLAN <run-base> <base-branch>`.
2. Dispatch `team-driven-development:reviewer` with `model: opus`, scope `final` (new section in `agents/reviewer.md` and `prompts/final-review-prompt.md`). Inputs (paths): review package, spec, plan, `common.md`, `ledger.md` (deferred minors + deferred/wont-fix dispositions). Output: `final-review.md`. Checks: cross-task integration, spec coverage of the whole, Shared Criteria in `common.md`, triage of deferred minors (must-fix-before-merge vs keep-deferred).
3. APPROVE → ledger `Final: review APPROVE`, go to C-2.
4. REQUEST_CHANGES (or any deferred minor triaged must-fix) → ONE fix Worker with the complete findings list (never one per finding), model `opus`, in a new worktree from current `<base-branch>` HEAD (Worktree Mode: current directory). Task brief = `final-review.md` path. Then one scoped re-review (`re-review-prompt.md`, reviewer model sonnet) over the fix range, then cherry-pick as in B-6.
5. No second fix wave. Residual open findings → listed in Completion Report `### Final Review Residuals` and surfaced to the user.

Ledger lines per step as in grammar. Completion Report gains a `### Final Review` section: verdict, findings count, fix commit, residuals.

### No-Subagents Contract

Added to `agents/worker.md` Rules and `prompts/worker-prompt.md`:

> You do not dispatch subagents. Do all task work yourself; never spawn a helper to implement part of the task and never spawn a reviewer. Self-review means reading your own diff. Review is the Lead's job after you report; a reviewer you spawn duplicates it at full cost and its verdict counts for nothing.

### Cleanup (C-4 extension)

C-4 prompt lists the run workspace alongside worktrees:

```
Run workspace: .team-dd/runs/<slug>/ (ledger, briefs, reports, reviews)
Worktrees from this session: ...
Clean up all? [Yes / No / Select]
```

Yes → also `rm -rf <ws>`. Workspace is kept automatically when any task is `escalated` or final residuals exist (prompt says so) unless user selects it explicitly.

### Error Handling

| Condition | Handling |
|---|---|
| `task-brief` exit 3 (heading not found) | Fall back: Lead writes the task text it extracted in A-1 to `task-N-brief.md` itself; ledger note |
| `review-package` exit 3 (empty range) | Worker reported DONE without commits → treat as NEEDS_CONTEXT: ask Worker to commit |
| Worker report file missing/empty on DONE | Send back once to same Worker; still missing → synthesise from commits + diff (existing rule) and ledger note |
| Ledger identity mismatch | Handled by `run-workspace` disambiguation |
| `.team-dd/` not writable | Abort before Phase B with error naming the path |

### Testing Strategy

- `tests/scripts/` bash test files (one per script) runnable via `bash tests/scripts/run.sh`; each creates a temp git repo, runs the script, asserts output/exit codes:
  - `run-workspace`: creates dir + `plan-path`; idempotent; create-only `.gitignore` (pre-existing custom file preserved); collision with different plan → disambiguated dir.
  - `task-brief`: extracts Task 2 from `skills/sprint-master/fixtures/valid-plan.md`; `### Task 1` does not match `Task 10`; heading inside code fence ignored; missing task → exit 3.
  - `review-package`: multi-commit range includes all commits; non-descendant → exit 3; empty range → exit 3; bad ref → exit 2.
- Skill text checks (grep-based, in same runner): `SKILL.md` no longer contains "Managed in Lead's context"; contains `max 5 rounds`, `ledger.md`, `Final Whole-Branch Review`; worker prompt contains no `[FULL TEXT from plan` / `[Paste Sprint Contract]` placeholders; `agents/worker.md` contains "You do not dispatch subagents".
- Manual dogfood: run Full Mode on `skills/sprint-master/fixtures/valid-plan.md` in a scratch repo; interrupt after Task 1 complete, restart, confirm Task 1 is skipped.

## File Changes

| File | Change |
|---|---|
| `skills/team-driven-development/scripts/run-workspace` | New |
| `skills/team-driven-development/scripts/task-brief` | New |
| `skills/team-driven-development/scripts/review-package` | New |
| `skills/team-driven-development/prompts/re-review-prompt.md` | New |
| `skills/team-driven-development/prompts/final-review-prompt.md` | New |
| `tests/scripts/run.sh`, `tests/scripts/test-*.sh` | New |
| `skills/team-driven-development/SKILL.md` | Review Ledger → file; Resume; A-1 brief extraction; B-2 file handoff; B-4 review package; B-5 rewrite; new C-1.5; C-2 reads ledger + Final Review section; C-4 workspace cleanup |
| `skills/team-driven-development/prompts/worker-prompt.md` | Paths-only dispatch, report file, short return, no-subagents |
| `skills/team-driven-development/prompts/reviewer-prompt.md` | Paths-only, output file, short return |
| `skills/team-driven-development/prompts/architect-prompt.md` | Paths instead of pasted contract/task |
| `agents/worker.md` | Report to file + short return contract; fix-round append; no-subagents rule; workspace write exception |
| `agents/reviewer.md` | Write report to output path; re-review mode; final scope |
| `README.md`, `docs/README.ja.md` | Workflow: ledger/resume, 5-round loop, final review; superpowers attribution |
| Not modified | Lite Mode section, `agents/sprint-master.md`, `agents/architect.md`, team-plan, brainstorm skills |
