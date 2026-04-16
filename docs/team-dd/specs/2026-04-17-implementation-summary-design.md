# Implementation Summary in Completion Report Design

## Overview

Enrich the Completion Report with three new sections — Implementation Summary, Test Results, and Deferred Items Detail — so users get a complete picture of what was built, whether tests passed, and what was explicitly deferred. Applies to both Full Mode (Phase C-2) and Lite Mode completion reports.

## Motivation

- The current Completion Report focuses entirely on review verdicts and findings
- Users have no quick way to see what was implemented without reading the commit log or diffs
- Test pass/fail counts are verified in C-3 but never surfaced in the report, leaving the completion evidence implicit
- Deferred findings are counted in Summary but their content and rationale are not recorded, making follow-up work harder

## Design

### Implementation Summary Content

Each task entry in the summary should describe:
- What was built or changed (one or two sentences)
- Key files created or modified (file paths)
- Notable decisions or patterns applied (if any)

### Full Mode: Worker Output Extension

Workers currently report status (`DONE`, `DONE_WITH_CONCERNS`, etc.) without a structured implementation summary. The Worker dispatch template (`worker-prompt.md`) must be updated to require a `## Implementation Summary` section in the Worker's output.

Worker output format (appended to existing DONE/DONE_WITH_CONCERNS):

```
## Status: DONE

## Implementation Summary
[2–4 sentences describing what was built]

## Files Changed
- Created: path/to/file — [purpose]
- Modified: path/to/file — [what changed]

## Commits
- abc1234: description
```

The Lead collects these summaries during B-3 (Handle Worker Status) and stores them per task alongside the Review Ledger.

### Lite Mode: Lead Self-Summary

In Lite Mode the Lead implements directly and already knows what was done. After completing each task, the Lead records a brief summary before moving to review. No new data source is needed — the Lead synthesises from its own actions.

### Completion Report Format Update

**Full Mode (C-2):**

```markdown
## Completion Report
### Tasks Completed: N/N
| Task | Status | Files | Profile | Rounds | Findings |
|------|--------|-------|---------|--------|----------|

### Implementation Summary
#### Task 1: [name]
[2–4 sentence description of what was built]
**Files:** path/to/file1, path/to/file2

#### Task N: [name]
...

### Review Detail (per task with findings)
| # | Source | Severity | Finding | Disposition | Detail |
|---|--------|----------|---------|-------------|--------|

### Summary
- Files changed / Commits / Architect consulted / Avg rounds / Findings / Deferred

### Commit Log
- hash: Task N - [description]
```

**Lite Mode:**

```markdown
## Completion Report (Lite Mode)
### Tasks Completed: N/N

### Implementation Summary
[2–4 sentence description of all changes combined, or per-task if N > 2]
**Files:** path/to/file1, path/to/file2

### Commit Log
- abc1234: Task 1 - [description]

### Review
- Verdict: [APPROVE | REQUEST_CHANGES → fixed round N]
- Findings: Nc, NM, Nm, Nr

### Review Detail (if findings)
| # | Severity | Finding | Disposition | Detail |
|---|----------|---------|-------------|--------|
```

### Test Results

Workers already run tests as part of TDD. The Lead verifies in C-3 that all tests pass, but the result is never shown in the report. The Worker output format should include a `### Test Results` section, and the Completion Report should surface a summary.

Worker output addition:
```
### Test Results
- `<cmd>`; N passed, N failed, N skipped
```

For Lite Mode, the Lead records test results from its own test runs before writing the report.

Completion Report surface (Full Mode, per task in the task table — add a "Tests" column):
```
| Task | Status | Files | Profile | Rounds | Findings | Tests |
```

Also add a standalone section (skip if all clean):
```markdown
### Test Results (skip if all clean)
| Task | Command | Passed | Failed | Skipped |
```

For Lite Mode, add below Commit Log:
```markdown
### Test Results
- `<cmd>`; N passed, 0 failed
```

### Deferred Items Detail

The current Summary line includes a "Deferred" count but no content. A deferred finding has a reason (wont-fix or deferred with justification) that is useful for follow-up work. Add a `### Deferred Items` section shown only when Deferred > 0.

```markdown
### Deferred Items (if any)
| # | Task | Severity | Finding | Disposition | Reason |
|---|------|----------|---------|-------------|--------|
```

This applies to both Full Mode and Lite Mode.

### Completion Report Format Update

**Full Mode (C-2):**

```markdown
## Completion Report
### Tasks Completed: N/N
| Task | Status | Files | Profile | Rounds | Findings | Tests |
### Implementation Summary
#### Task N: [name]
[What was built — 2–4 sentences] **Files:** f1, f2
### Test Results (skip if all clean)
| Task | Command | Passed | Failed | Skipped |
### Review Detail (per task with findings)
| # | Source | Severity | Finding | Disposition | Detail |
### Deferred Items (skip if none)
| # | Task | Severity | Finding | Disposition | Reason |
### Summary
- Files changed / Commits / Architect consulted / Avg rounds / Findings / Deferred
### Commit Log
- hash: Task N - description
```

**Lite Mode:**

```markdown
## Completion Report (Lite Mode)
### Tasks Completed: N/N
### Implementation Summary
[What was built — 2–4 sentences. Per-task if N > 2.] **Files:** f1, f2
### Commit Log
- hash: Task N - description
### Test Results
- `<cmd>`; N passed, 0 failed
### Review
- Verdict: APPROVE | REQUEST_CHANGES → fixed round N
- Findings: Nc, NM, Nm, Nr
### Review Detail (skip if none)
| # | Severity | Finding | Disposition | Detail |
### Deferred Items (skip if none)
| # | Severity | Finding | Disposition | Reason |
```

### Error Handling

- Missing `### Implementation Summary` → synthesise from commits+diff.
- Missing `### Test Results` → record "not reported" in Tests column.
- `### Deferred Items` / `### Test Results` (Full) → skip entirely when empty.

### Testing Strategy

Since SKILL.md is a prompt document rather than executable code, verification is done by:
- Reading updated SKILL.md and worker-prompt.md to confirm consistent formatting
- Manually running a plan through team-driven-development and confirming all new sections appear in the Completion Report

## File Changes

| File | Change |
|------|--------|
| `skills/team-driven-development/SKILL.md` | Add `### Implementation Summary`, `### Test Results`, and `### Deferred Items` to Full Mode (C-2) and Lite Mode reports; update B-3 summary capture; update C-1 |
| `skills/team-driven-development/prompts/worker-prompt.md` | Add `### Implementation Summary`, `### Test Results` to Worker output format |
| `docs/team-dd/specs/2026-04-17-implementation-summary-design.md` | New (this file) |
