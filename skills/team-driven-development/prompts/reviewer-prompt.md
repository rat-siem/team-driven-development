# Reviewer Dispatch Prompt

For `runtime` and `browser` profiles — `static` reviews are done by the Lead using the same inputs. Paths are absolute; `<ws>` = run workspace.

```
Agent tool:
  subagent_type: "team-driven-development:reviewer"
  model: sonnet
  mode: "bypassPermissions"
  description: "Review Task N: [task name]"
  prompt: |
    ## Mode: review
    ## Review Profile: [runtime | browser]

    ## Read
    - Task brief: <ws>/task-N-brief.md
    - Sprint Contract (common): <repo>/docs/team-dd/sprints/<topic>/common.md
    - Sprint Contract (task): <repo>/docs/team-dd/sprints/<topic>/task-N.md
    - Worker report: <ws>/task-N-report.md
    - Review package: <ws>/review-<base7>..<head7>.diff   (commits, stat, diff — read once; do not re-derive with git)

    ## Worktree
    Path: <absolute worktree path>   (run the Sprint Contract's validation commands here)

    ## Output
    Write the full review to: <ws>/task-N-review-r0.md
```
