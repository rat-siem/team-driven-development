# Worktree-Aware Execution Design

## Overview

When team-driven-development is invoked from inside a git worktree, sub-worker worktrees created via `isolation: "worktree"` branch from the main repo and miss the current worktree's work. This feature auto-detects the worktree context and switches to a simpler execution mode: workers commit directly to the current worktree branch, eliminating both the isolation overhead and the cherry-pick/cleanup phases.

## Motivation

- Workers dispatched with `isolation: "worktree"` base from the main repo, not the calling worktree
- Uncommitted and committed-but-not-merged work in the current worktree is invisible to sub-workers
- Cherry-pick is an artifact of worktree isolation — without sub-worktrees it is unnecessary
- Worktree Cleanup (C-4) has nothing to clean up when no sub-worktrees were created

## Design

### Worktree Detection

At Phase A-0 (Triage), before mode selection, Lead checks whether it is running inside a git worktree:

```bash
test -f .git && echo "worktree" || echo "main"
```

When inside a worktree, `.git` is a file (containing a `gitdir:` pointer) rather than a directory. This is a reliable, portable detection method with no external dependencies.

If detected: announce once and activate Worktree Mode.

> `"Running in worktree context — workers will commit directly to this branch (no sub-worktrees)."`

### Worktree Mode vs Full Mode

| Aspect | Full Mode | Worktree Mode |
|--------|-----------|---------------|
| Worker isolation | `isolation: "worktree"` | None — current branch |
| Cherry-pick (B-6) | Yes → main | Skipped |
| Verify (C-3) | Tests pass on main | Tests pass on current branch |
| Worktree Cleanup (C-4) | Offer cleanup | Skipped (nothing to clean) |
| Execution order | Dependency order, up to 2 parallel | Sequential only |
| Everything else | Unchanged | Unchanged |

All phases (0, A-0 through A-6, B-1 through B-5, C-1 through C-2) run identically. Worktree Mode is not a new mode — it is Full Mode with three steps removed.

### Sequential Execution

Worktree Mode enforces strictly sequential task execution (no parallel Workers). Without worktree isolation, parallel Workers sharing the same working tree would conflict. The existing rule of "up to 2 parallel Workers" does not apply.

### Lite Mode Interaction

Lite Mode already has no sub-worktrees, so it is unaffected by worktree context. If the user selects Lite Mode while in a worktree, it runs exactly as normal.

If triage proposes Lite Mode and the user accepts: proceed normally (no Worktree Mode announcement needed).

If triage proposes or selects Full Mode while in a worktree: activate Worktree Mode.

### Error Handling

No special error handling beyond the existing BLOCKED/NEEDS_CONTEXT paths. If a Worker fails mid-execution in Worktree Mode, its partial commits remain on the current branch (same as Lite Mode behavior). The Lead reports the failure and stops.

### Testing Strategy

Manual verification:
- Run team-driven-development from inside a worktree, confirm detection message appears
- Confirm Workers commit to the current branch without creating sub-worktrees
- Confirm no cherry-pick or cleanup prompt appears
- Confirm `git worktree list` shows no new entries after execution
- Run from main repo: confirm normal Full Mode (detection fires false, no change)

## File Changes

| File | Change |
|------|--------|
| `skills/team-driven-development/SKILL.md` | Add worktree detection to Phase A-0; add Worktree Mode table; annotate B-6 and C-3/C-4 with skip conditions |
| `docs/team-dd/specs/2026-04-16-worktree-aware-execution-design.md` | New — this file |
| `docs/team-dd/plans/2026-04-16-worktree-aware-execution.md` | New — implementation plan |
