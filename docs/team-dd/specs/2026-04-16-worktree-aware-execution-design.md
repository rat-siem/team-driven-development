# Worktree-Aware Execution Design

## Overview

When team-driven-development is invoked from inside a git worktree, sub-worker worktrees created via `isolation: "worktree"` branch from the main repo and miss the current worktree's work. This feature auto-detects the worktree context and switches Workers to commit directly to the current branch — eliminating sub-worktree creation, cherry-pick, and cleanup.

## Motivation

- Workers dispatched with `isolation: "worktree"` base from the main repo, not the calling worktree
- Uncommitted and committed-but-not-merged work in the current worktree is invisible to sub-workers
- Cherry-pick and Worktree Cleanup are artifacts of sub-worktree isolation — without it, both are unnecessary

## Design

### Detection

At Phase A-0 (before triage), run:

```bash
git rev-parse --git-dir
```

If the output contains `/worktrees/` (e.g. `/repo/.git/worktrees/feature-x`), the Lead is inside a worktree. This is reliable and does not trigger on submodules (which return `.git` or `.git/modules/…`).

Additional guards before activating Worktree Mode:

1. **Refuse on main/master**: if current branch is `main` or `master`, stop with: `"Worktree Mode cannot run on main/master — switch to a feature branch first."` (Committing Workers directly to main violates the plugin's branch protection principle.)
2. **Clean tree required**: run `git diff-index --quiet HEAD --`. If it fails (uncommitted changes exist), stop with: `"Worktree Mode requires a clean working tree — commit or stash your changes first."`

### Worktree Mode vs Full Mode

| Aspect | Full Mode | Worktree Mode |
|--------|-----------|---------------|
| B-2 Worker dispatch | `isolation: "worktree"` | Omit `isolation` — worker runs in current directory |
| Parallel Workers | Up to 2 | Sequential only |
| B-6 Cherry-pick | Yes → main | **Skipped** |
| C-3 Verify | Tests pass on main | Tests pass on current branch |
| C-4 Worktree Cleanup | Offer cleanup | **Skipped** |
| Rollback reference | n/a | Record `HEAD` SHA before each Worker dispatch |
| Everything else | Unchanged | Unchanged |

Worktree Mode is not a new mode — it is Full Mode with guards, two phases skipped, and `isolation` removed from B-2.

### Rollback Reference

Before dispatching each Worker, record `git rev-parse HEAD`. If a Worker fails, the failure report includes: `"To undo this task: git reset --soft <sha>"`.

### Lite Mode Interaction

Lite Mode already has no sub-worktrees and is unaffected by worktree context. If triage selects Lite Mode while in a worktree, it runs normally (no Worktree Mode announcement needed).

### Future Enhancement

Sub-worktrees could be created from the current worktree's HEAD (`git worktree add … HEAD`) rather than from main. This would restore per-task isolation and allow parallel execution, at the cost of additional complexity and requiring committed work. Not in scope for this feature.

### SKILL.md Text (target)

The following is the actual text to add to SKILL.md, written for minimal tokens while covering all required behaviors:

---

**Add to Phase A-0, before Quick Score:**

```markdown
### Worktree Check

Run: `git rev-parse --git-dir`

If output contains `/worktrees/` → **Worktree Mode** (announce: *"Running in worktree context."*):
- Refuse if branch is main/master.
- Refuse if `git diff-index --quiet HEAD --` fails (uncommitted changes — commit or stash first).
- Workers commit directly to this branch. Omit `isolation: "worktree"` from B-2 dispatch. Sequential only.
- Skip B-6. C-3: verify on current branch. Skip C-4.
- Record `git rev-parse HEAD` before each Worker. On failure, report: `git reset --soft <sha>` to undo.
```

---

Total addition: 10 lines. Covers detection, guards, dispatch change, skipped phases, and rollback.

## Testing Strategy

Manual verification:
- From inside a worktree on a feature branch with clean tree: confirm announcement, Workers commit to current branch, no sub-worktrees created, no cherry-pick prompt
- From inside a worktree on main: confirm refusal message
- From inside a worktree with dirty tree: confirm refusal message
- From a submodule: confirm Worktree Mode does NOT activate
- From main repo: confirm normal Full Mode (no detection change)

## File Changes

| File | Change |
|------|--------|
| `skills/team-driven-development/SKILL.md` | Add Worktree Check section to Phase A-0 (10 lines) |
| `docs/team-dd/specs/2026-04-16-worktree-aware-execution-design.md` | This file |
| `docs/team-dd/plans/2026-04-16-worktree-aware-execution.md` | New — implementation plan |
