# Review Ledger & Review Quality Improvements

**Date:** 2026-04-15
**Status:** Approved
**Scope:** team-driven-development plugin v0.1.x

## Problem

1. **Review traceability gap** — After a process completes, there is no record of what the Reviewer checked, what was found, or how findings were resolved. Running a separate review after the process sometimes surfaces issues that the in-process review missed.
2. **Static review has no structure** — The most frequently used review profile (`static`) has no template. Lead reviews diffs ad-hoc with no structured output.
3. **Worker self-review and Reviewer findings are disconnected** — Worker produces free-form self-review; Reviewer checks Sprint Contract criteria. No mechanism to compare the two or identify what the Worker missed.
4. **Cherry-pick conflict handling is undefined** — Phase B-6 assumes `git cherry-pick` always succeeds. Parallel tasks touching adjacent lines can cause conflicts with no defined resolution path.
5. **Sprint Contract validation is absent** — Contracts go from generation to Worker dispatch with no quality gate. Vague criteria propagate into weak reviews.

## Design

### 1. Review Ledger

A structured tracking artifact managed by the Lead for each task. Accumulates all review findings across Worker self-review and Reviewer rounds, and tracks the disposition of every finding.

#### Format

```markdown
## Review Ledger: Task N - [Task Name]

### Round 1

#### Worker Self-Review
| # | Severity | File:Line | Finding | Source |
|---|----------|-----------|---------|--------|
| W-1 | minor | src/foo.ts:42 | Unused import | self-review |

#### Reviewer Findings
| # | Severity | File:Line | Finding | Source |
|---|----------|-----------|---------|--------|
| R-1 | major | src/bar.ts:15 | Missing null check on API response | reviewer |
| R-2 | minor | src/bar.ts:30 | Variable name unclear | reviewer |

#### Disposition
| # | Source | Severity | Disposition | Detail |
|---|--------|----------|-------------|--------|
| W-1 | self-review | minor | fixed | Removed in same commit |
| R-1 | reviewer | major | fixed | Added null check, commit abc123 |
| R-2 | reviewer | minor | deferred | Style preference, no functional impact |

### Round 2
(structure repeats if REQUEST_CHANGES triggers re-review)

### Final Status: APPROVE (Round N)
```

#### Rules

- **Three dispositions only:** `fixed` (resolved), `deferred` (out of scope — reason required), `wont-fix` (not actionable — reason required).
- **critical/major findings MUST be `fixed`.** Only minor/recommendation findings may be `deferred` or `wont-fix`.
- Lead verifies all criteria show MET in the Ledger before proceeding to cherry-pick.
- Ledger is managed in Lead's context (not written to filesystem). It feeds into the Completion Report.

### 2. Reviewer Prompt Enhancement

Three changes to the Reviewer dispatch prompt (`prompts/reviewer-prompt.md`):

#### A. Sprint Contract Checklist — Mandatory Evidence Table

Replace the current checklist format:

```markdown
### Sprint Contract Checklist
| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | GET /api/users returns 200 | MET | Verified in test output |
| 2 | User model exports name, email | MET | Confirmed in src/models/user.ts:5-8 |
| 3 | Tests pass: pytest tests/ | NOT_MET | 2 failures in test_users.py |

Coverage: 3/3 criteria evaluated
```

- `SKIPPED` is not allowed. Every criterion must be `MET` or `NOT_MET`.
- `Evidence` column explains what was observed to reach the verdict.

#### B. Finding IDs

All findings receive a unique ID (`R-1`, `R-2`, ...) for Ledger traceability:

```markdown
#### Major
- **R-1** src/bar.ts:15 — Missing null check on API response

#### Minor
- **R-2** src/bar.ts:30 — Variable name `d` is unclear
```

#### C. Static Review Template

Add a structured template for `static` profile reviews in SKILL.md Phase B-4. Lead uses the same output format as runtime/browser Reviewers:

```markdown
**static (Lead reviews directly):**
1. Read the Worker's diff
2. Check each Sprint Contract criterion → record in Ledger with Evidence
3. Verify non-goals were respected
4. Output structured review using the same format as runtime/browser
5. Verdict: APPROVE or REQUEST_CHANGES with specific issues
```

### 3. Worker Self-Review Structuring

Change the Worker prompt's Report Format to produce Ledger-compatible output:

```markdown
## Report Format

- **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
- **What you implemented:** [summary]
- **Test results:** [commands + output]
- **Files changed:** [full list]

### Self-Review Findings
| # | Severity | File:Line | Finding | Action |
|---|----------|-----------|---------|--------|
| W-1 | minor | src/foo.ts:42 | Unused import | fixed |
| W-2 | major | src/bar.ts:15 | Edge case not handled | fixed |

If no findings: "Self-review complete. No issues found."

- **Concerns** (if DONE_WITH_CONCERNS): [description]
```

The existing self-review checklist (Completeness / Quality / Discipline / Testing) remains as the execution guide. The structured table is the output format for findings discovered during that checklist.

### 4. Sprint Contract QA (Phase A-5.5)

A validation gate inserted between Contract generation (A-5) and team composition (A-6).

#### Contract QA Checklist

```
1. [ ] All Success Criteria are specific and verifiable
       NG: "Code works correctly"
       OK: "GET /api/users returns 200 with JSON array"
2. [ ] Test commands include file paths or filters
3. [ ] At least one Non-Goal is defined
4. [ ] Reviewer Profile matches task characteristics
5. [ ] Dependencies on incomplete tasks are stated as preconditions
```

#### Failure Handling

- Lead fixes the Contract directly (no external agent needed).
- Re-check once after fix. If still failing, the task definition itself is ambiguous — escalate to human.

#### Placement in Process

```
A-5:   Generate Sprint Contracts
A-5.5: Contract QA (NEW)
A-6:   Determine team composition
```

### 5. Cherry-pick Conflict Handling

Added to Phase B-6:

```
B-6: Cherry-pick to Main

On APPROVE:
  git cherry-pick --no-commit <worktree-commit-hash>

If conflict:
  1. Lead resolves directly.
     - Read conflict markers.
     - Resolve using both task's intent and existing main state.
  2. If resolution is non-trivial (semantic conflict, not adjacency):
     - Re-dispatch Reviewer on the resolved result.
     - One additional review round (does not count toward 3-round limit).
  3. If Lead cannot resolve:
     - Escalate to human with conflict details and both sides' intent.
  4. Record in Ledger: "Cherry-pick conflict resolved by Lead"
     or "Re-reviewed after conflict resolution".
```

### 6. Completion Report Enhancement

The Completion Report pulls from Review Ledger data:

```markdown
## Completion Report

### Tasks Completed: N/N

| Task | Status | Files | Profile | Rounds | Findings |
|------|--------|-------|---------|--------|----------|
| 1    | Done   | 3     | static  | 1      | 0 critical, 0 major, 1 minor |
| 2    | Done   | 7     | runtime | 2      | 0 critical, 1 major, 2 minor |

### Review Detail

#### Task 2 - [Name]
| # | Source | Severity | Finding | Disposition | Detail |
|---|--------|----------|---------|-------------|--------|
| W-1 | self-review | minor | Unused import | fixed | — |
| R-1 | reviewer | major | Missing null check | fixed | Round 2, commit def567 |
| R-2 | reviewer | minor | Variable naming | deferred | Style preference |

### Summary
- Total files changed: N
- Total commits: N
- Architect consulted: Tasks [2, 5]
- Review rounds: avg N per task
- Findings: N critical, N major, N minor, N recommendations
- Deferred items: N (see Review Detail for reasons)

### Commit Log
- abc1234: Task 1 - [description]
- def5678: Task 2 - [description]
```

- Tasks with zero findings omit the Review Detail section.
- Deferred count and reasons are surfaced in the Summary.

## Files to Modify

| File | Change |
|------|--------|
| `skills/team-driven-development/SKILL.md` | Add Review Ledger concept, Phase A-5.5, static review template, cherry-pick conflict handling, enhanced Completion Report |
| `skills/team-driven-development/prompts/reviewer-prompt.md` | Evidence table, finding IDs, no-SKIPPED rule |
| `skills/team-driven-development/prompts/worker-prompt.md` | Structured self-review output format |
| `skills/team-driven-development/sprint-contract-template.md` | Add Contract QA checklist reference |
| `agents/reviewer.md` | Add Evidence requirement to report format |
| `agents/worker.md` | Add structured self-review finding format |

## Non-Goals

- Ledger is NOT persisted to filesystem (managed in Lead's context only).
- No cross-session learning or metrics collection (future work).
- No changes to Architect role or prompt.
- No changes to Lite Mode review process beyond applying the same Reviewer prompt enhancements.
- No changes to effort scoring or model selection.

## Lite Mode Impact

Lite Mode uses the same Reviewer prompt, so it benefits from:
- Evidence table (change A)
- Finding IDs (change B)
- Structured Completion Report (change 6, using Lite Mode format)

Lite Mode does NOT use:
- Review Ledger (single review round, no multi-round tracking needed)
- Contract QA (no Sprint Contracts in Lite Mode)
- Cherry-pick conflict handling (no worktrees in Lite Mode)
