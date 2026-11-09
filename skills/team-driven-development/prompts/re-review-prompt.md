# Scoped Re-Review Prompt

Adapted from obra/superpowers (MIT License, Copyright (c) 2025 Jesse Vincent).

Dispatched after each fix round (B-5) and after the final fix wave (C-1.5). `static` profile: the Lead performs the re-review itself under the same rules (agents/reviewer.md `## Mode: re-review`).

```
Agent tool:
  subagent_type: "team-driven-development:reviewer"
  model: sonnet
  mode: "bypassPermissions"
  description: "Re-review Task N fix round R"
  prompt: |
    ## Mode: re-review
    ## Review Profile: [runtime | browser]

    ## Findings Under Verification (verbatim)
    - [finding ID — one-liner]
    Verdict per ID: ADDRESSED | NOT ADDRESSED. Issues outside the fix diff: Out-of-Scope Observations only.

    ## Read
    - Task brief: <ws>/task-N-brief.md          [final wave: <ws>/final-review.md]
    - Worker report (fix sections appended): <ws>/task-N-report.md
    - Fix package: <ws>/review-<fixbase7>..<head7>.diff   (FIX_BASE = head the previous review saw)

    ## Worktree
    Path: <absolute worktree path>

    ## Output
    Write the full re-review to: <ws>/task-N-review-rR.md   [final wave: <ws>/final-review-r1.md]
```
