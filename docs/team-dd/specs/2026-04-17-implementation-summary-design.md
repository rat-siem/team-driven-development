# Implementation Summary in Completion Report Design

## Overview

Add an implementation summary section to the Completion Report so that users can see not only review findings but also what was actually built. This applies to both Full Mode (Phase C-2) and Lite Mode completion reports.

## Motivation

- The current Completion Report focuses entirely on review verdicts and findings
- Users have no quick way to see what was implemented without reading the commit log or diffs
- An implementation summary provides a human-readable account of changes made, helping stakeholders understand the outcome of a run

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

### Error Handling

If a Worker's DONE output does not include an `## Implementation Summary` section, the Lead synthesises it from the commit messages and file diff before completing the task.

### Testing Strategy

Since SKILL.md is a prompt document rather than executable code, verification is done by:
- Reading the updated SKILL.md and worker-prompt.md to confirm consistent formatting
- Manually running a TDD plan through team-driven-development and confirming the Completion Report includes the Implementation Summary section

## File Changes

| File | Change |
|------|--------|
| `skills/team-driven-development/SKILL.md` | Add `### Implementation Summary` section to both Full Mode (C-2) and Lite Mode Completion Reports; add collection step in C-1; update B-3 to note summary capture |
| `skills/team-driven-development/prompts/worker-prompt.md` | Add `## Implementation Summary` output section to expected Worker output |
| `docs/team-dd/specs/2026-04-17-implementation-summary-design.md` | New (this file) |
