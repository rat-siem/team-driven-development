# Worktree Base Branch Selection Design

**Base branch:** develop

## Overview

Worker worktrees currently materialize from `main` regardless of the Lead's current branch, hiding in-progress work and breaking integration. This change defaults Worker worktrees to the current branch, propagates an explicit base-branch decision through the skill chain via document recording, adds a `--branch=<name>` override, and replaces opaque `isolation: "worktree"` with Lead-managed `git worktree add`.

## Motivation

- Sub-agent worktrees branch from `main`, missing committed-but-not-merged work on the active feature branch.
- No mechanism asks the user which branch to base on, nor records the answer for downstream skills.
- No CLI escape for users who already know the target branch and want to skip the question.
- `isolation: "worktree"` is a black box — moving worktree creation under Lead control makes the base branch explicit and auditable.

## Design

### Base Branch Resolution

Each of `quick-brainstorm`, `deep-brainstorm`, `team-plan`, and `team-driven-development` resolves the base branch using the same algorithm at the earliest point it owns:

1. **`--branch=<name>` argument present** → run `git rev-parse --verify <name>`.
   - Verified → record and proceed without prompt.
   - Not found → prompt: `Branch '<name>' not found. Choose: [1] use current branch '<current>' / [2] specify another / [3] cancel`. Apply the user's response; cancel terminates the skill.
2. **No flag, but the upstream document already records `**Base branch:**`** → reuse that value, no prompt.
3. **No flag, no recorded value** → prompt: `Base Worker worktrees on current branch '<current>'? Reply yes, or specify another branch.` Reuse current on plain affirmative; otherwise treat the response as the branch name and verify (loop on missing).

The resolved value is recorded in the document the skill owns (spec, plan, or — for `team-driven-development` — only in the in-memory Lead context, since execution writes no upstream document).

### `--branch=<name>` Argument

- All four skills accept `--branch=<name>` as an additional argument after their existing positional arguments.
- The flag suppresses the confirmation prompt unless the branch does not exist (which forces the missing-branch prompt above).
- Quoting and escaping follow shell conventions; the value is treated as a plain branch name (no glob, no remote-tracking syntax).

### Recording in Documents

**Spec header** (after the `# Title` line):

```markdown
# <Feature> Design

**Base branch:** <name>

## Overview
...
```

**Plan header** (existing metadata block):

```markdown
**Goal:** ...
**Architecture:** ...
**Tech Stack:** ...
**Spec:** <path>
**Sprints:** docs/team-dd/sprints/<topic>/
**Base branch:** <name>
```

**Sprint Contract `common.md`** — `sprint-master` copies the value from the plan into a `Base branch:` field at the top of `common.md` so Workers and Reviewers see it without reading the plan.

When a downstream skill reads the upstream document and finds `**Base branch:**`, it skips the prompt. Missing field → run resolution.

### Per-Skill Behavior

| Skill | Reads from | Records to | When prompt fires |
|---|---|---|---|
| `quick-brainstorm` | nothing upstream | spec header | Always (unless `--branch`) |
| `deep-brainstorm` | nothing upstream | spec header | Always (unless `--branch`) |
| `team-plan` | spec header | plan header | Spec lacks the field, no `--branch` |
| `team-driven-development` | plan header | Lead context | Plan lacks the field, no `--branch` |

`sprint-master` does not run resolution; it only mirrors the plan's value into `common.md`.

### Worker Dispatch Change (Option A)

Replace `isolation: "worktree"` with Lead-managed worktree creation in `team-driven-development` Phase B-2.

**Before each Worker dispatch, Lead runs:**

```bash
git worktree add .claude/worktrees/agent-<task-id> -b worktree-agent-<task-id> <base-branch>
```

- `<task-id>` is unique per task (e.g., random suffix or task index) to allow parallelism.
- `<base-branch>` is the resolved value.
- The new branch `worktree-agent-<task-id>` is the Worker's working branch; commits land there.

**Agent dispatch parameters:**

- Drop `isolation: "worktree"`.
- Pass the absolute worktree path in the prompt as `## Worktree`.
- Worker is instructed to `cd <path>` before any git or build commands.

**Worker prompt addition (`prompts/worker-prompt.md`):**

```
## Worktree
Path: <absolute path>
Branch: worktree-agent-<task-id>
Base: <base-branch>

All commands run inside this path. Do not modify files outside it.
```

**Worker agent (`agents/worker.md`)** — add a sentence to Rules: "Operate exclusively inside the worktree path provided in the dispatch prompt; do not navigate above it."

### B-6: Cherry-pick to Base Branch (renamed from "Cherry-pick to Main")

```bash
git checkout <base-branch>
git cherry-pick --no-commit <hash>
git commit -m "<task description>"
```

The integration target is the base branch, not always `main`. All other B-6 logic (conflict handling, Reviewer re-dispatch on non-trivial conflicts, escalation) is unchanged.

### Worktree Mode Interaction

Existing behavior (Lead detected to be inside a worktree via `git rev-parse --git-dir` containing `/worktrees/`) is **unchanged**:

- Workers run in the current directory.
- No sub-worktree creation.
- B-6 is skipped.

Worktree Mode short-circuits before base-branch resolution because there is no sub-worktree to base. The `--branch` flag is ignored in Worktree Mode (warn: `--branch ignored: running in worktree context, Workers commit to current branch '<current>'`).

### Lite Mode Interaction

Lite Mode has no Workers and no sub-worktrees. Base-branch resolution still runs at skill entry (so the plan records the value for any later switch to Full Mode), but the recorded value has no Lite-Mode effect beyond informational display.

### Worktree Cleanup (C-4)

Unchanged. The Lead-created `.claude/worktrees/agent-<task-id>` paths are listed and removed via the existing C-4 dialog.

## Error Handling

- **`git worktree add` fails** (e.g., path already exists, branch name collision): Lead emits the error verbatim, retries once with a fresh `<task-id>`, then escalates.
- **Cherry-pick onto base branch fails** (conflict): existing B-6 conflict path applies; Reviewer re-dispatch happens on the same base branch.
- **`--branch` value contains shell metacharacters**: reject with `Invalid branch name: '<value>'`. Do not pass to git.
- **Recorded base branch deleted between skill steps** (e.g., user merges and prunes between `team-plan` and execution): `team-driven-development` re-validates at Phase A-0; on missing branch, falls back to the missing-branch prompt.

## Testing Strategy

Manual verification scenarios:

- **No flag, on `develop`** → prompt asks; user accepts; spec records `develop`; downstream skips prompts; Workers branch from `develop`; cherry-pick onto `develop`.
- **`--branch=feature/x` (exists)** → no prompt; recorded; Workers branch from `feature/x`.
- **`--branch=feature/missing`** → missing-branch prompt; choosing "use current" records the current branch.
- **Brainstorm records `develop`, then user runs `team-plan` with `--branch=feature/x`** → flag wins; plan records `feature/x`; execution uses `feature/x`.
- **Inside a worktree** → `--branch` is ignored with warning; existing Worktree Mode behavior intact.
- **Parallel dispatch (2 Workers)** → two distinct worktree paths and branches, no collision.

## File Changes

| File | Status | Responsibility |
|---|---|---|
| `skills/quick-brainstorm/SKILL.md` | Modify | Add base-branch resolution step before spec generation; spec template gains `**Base branch:**` line |
| `skills/deep-brainstorm/SKILL.md` | Modify | Add base-branch resolution to Phase 1 entry; spec template gains `**Base branch:**` |
| `skills/team-plan/SKILL.md` | Modify | Resolution step that prefers spec value; plan header gains `**Base branch:**` |
| `skills/team-driven-development/SKILL.md` | Modify | Resolution at Phase A-0 (after Worktree Check); B-2 dispatches with Lead-created worktree; B-6 cherry-picks onto base branch; rename "Cherry-pick to Main" → "Cherry-pick to Base Branch"; record `--branch` ignored warning in Worktree Mode |
| `skills/team-driven-development/prompts/worker-prompt.md` | Modify | Drop `isolation: "worktree"`; add `## Worktree` block with path/branch/base |
| `agents/worker.md` | Modify | Add rule: operate exclusively inside provided worktree path |
| `agents/sprint-master.md` | Modify | Copy plan's `**Base branch:**` value into `common.md` `Base branch:` field |
| `docs/team-dd/specs/2026-05-07-worktree-base-branch-design.md` | Create | This file |
| `docs/team-dd/plans/2026-05-07-worktree-base-branch.md` | Create | Implementation plan (by `team-plan`) |
