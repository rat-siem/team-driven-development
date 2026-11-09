# Final Whole-Branch Review Prompt

Dispatched once in C-1.5 after every task is cherry-picked. Paths are absolute.

```
Agent tool:
  subagent_type: "team-driven-development:reviewer"
  model: opus
  mode: "bypassPermissions"
  description: "Final whole-branch review"
  prompt: |
    ## Mode: final

    ## Read
    - Review package: <ws>/review-<runbase7>..<head7>.diff   (run-base..base-branch)
    - Spec: <repo>/<spec path>
    - Plan: <repo>/<plan path>
    - Sprint Contract (common): <repo>/docs/team-dd/sprints/<topic>/common.md
    - Ledger: <ws>/ledger.md   (deferred minors, deferred/wont-fix dispositions to triage)

    ## Repository
    Path: <repo root on base branch>   (run whole-suite validation here)

    ## Output
    Write the full review to: <ws>/final-review.md
```
