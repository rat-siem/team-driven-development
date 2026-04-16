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

Guard before activating Worktree Mode:

- **Clean tree required**: run `git diff-index --quiet HEAD --`. If it fails (uncommitted changes exist), stop with: `"Commit or stash changes first."`

### Worktree Mode vs Full Mode

| Aspect | Full Mode | Worktree Mode |
|--------|-----------|---------------|
| B-2 Worker dispatch | `isolation: "worktree"` | Omit — worker runs in current directory |
| B-6 Cherry-pick | Yes → main | **Skipped** |
| Everything else | Unchanged | Unchanged (LLM infers consequences) |

Worktree Mode is not a new mode — it is Full Mode with one guard, one parameter removed from B-2, and B-6 skipped.

### Lite Mode Interaction

Lite Mode already has no sub-worktrees and is unaffected by worktree context. If triage selects Lite Mode while in a worktree, it runs normally (no Worktree Mode announcement needed).

### Future Enhancement

Sub-worktrees could be created from the current worktree's HEAD (`git worktree add … HEAD`) rather than from main. This would restore per-task isolation and allow parallel execution, at the cost of additional complexity and requiring committed work. Not in scope for this feature.

### SKILL.md Text (target)

Add to Phase A-0, before Quick Score:

```markdown
### Worktree Check

Run: `git rev-parse --git-dir`

If output contains `/worktrees/` → **Worktree Mode**:
- Refuse if `git diff-index --quiet HEAD --` fails → `"Commit or stash changes first."`
- Announce: `"Running in worktree context."`
- B-2: omit `isolation: "worktree"`.
- Skip B-6.
```

6 lines. Covers detection, dirty-tree guard, announcement, dispatch change, and B-6 skip.

## Testing Strategy

Manual verification:
- Worktree, clean tree → announcement appears, Workers commit to current branch, no sub-worktrees, no cherry-pick prompt
- Worktree, dirty tree → refusal message
- Submodule → Worktree Mode does NOT activate
- Main repo → normal Full Mode (no change)

## File Changes

| File | Change |
|------|--------|
| `skills/team-driven-development/SKILL.md` | Add Worktree Check section to Phase A-0 (10 lines) |
| `docs/team-dd/specs/2026-04-16-worktree-aware-execution-design.md` | This file |
| `docs/team-dd/plans/2026-04-16-worktree-aware-execution.md` | New — implementation plan |
