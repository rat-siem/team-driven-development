# Worker Dispatch Prompt

Paths are absolute. `<ws>` = run workspace (SKILL.md A-0). Never paste plan text, contract text, or prior-task summaries.

## Initial Dispatch

```
Agent tool:
  subagent_type: "team-driven-development:worker"
  model: [haiku|sonnet|opus per Effort Score]
  mode: "bypassPermissions"
  description: "Implement Task N: [task name]"
  prompt: |
    ## Worktree
    Path: <absolute path to .claude/worktrees/agent-<task-id>>
    Branch: worktree-agent-<task-id>
    Base: <base-branch>

    All commands run inside this path. Do not modify files outside it, except your report file.

    ## Read First
    These files are your requirements. Read them before starting; use exact values verbatim.
    - Task brief: <ws>/task-N-brief.md
    - Sprint Contract (common): <repo>/docs/team-dd/sprints/<topic>/common.md
    - Sprint Contract (task): <repo>/docs/team-dd/sprints/<topic>/task-N.md
    - Design brief: <ws>/task-N-design.md          [omit line if no Architect]
    - Domain Guidelines: <repo>/guidelines/<domain>.md   [one line each; omit if none]

    ## Context From Lead
    [One line: where this task fits]
    [Interfaces/decisions from earlier tasks the brief cannot know]
    [Lead's resolution of any brief ambiguity]
    [Reference files: path — one-line description. No file contents. ≤ 2 KB total.]

    If anything is unclear — requirements, approach, dependencies — ask now.

    ## You Do Not Dispatch Subagents
    Do all task work yourself. Never spawn a helper to implement part of the task and never spawn a reviewer. Self-review means reading your own diff. Review is the Lead's job after you report; a reviewer you spawn duplicates it at full cost and its verdict counts for nothing.

    ## Report
    Write your full report to: <ws>/task-N-report.md
    Final message — this contract only:
    Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
    Commits: <sha7> <subject>   (one per line)
    Tests: <one line, e.g. "14/14 passing">
    Report: <ws>/task-N-report.md
    Concerns: <DONE_WITH_CONCERNS only>
    NEEDS_CONTEXT / BLOCKED: put the specifics in the final message itself.
```

## Fix Round 1–3 (resume the same Worker)

```
SendMessage:
  to: <agent id from the ledger `dispatched` line>
  message: |
    Fix round R/5 for Task N. Open findings (verbatim):
    - [finding]
    Fix them in the same worktree. Re-run the tests covering the amended code, commit, append `## Fix Round R` to <ws>/task-N-report.md (findings addressed, covering tests, command, output), and reply with the same short contract.
```

`SendMessage` unavailable or failing → use the Fresh Worker template on the round's model.

## Fresh Worker (rounds 4–5, resume fallback, resume after restart)

Same as Initial Dispatch, with: model one tier above the original (haiku→sonnet→opus; opus stays opus) for rounds 4–5; the existing worktree path (do not recreate it); and this section inserted before `## Report`:

```
    ## Prior Attempts
    A prior Worker attempted this task <R-1> times; you own it now. Read <ws>/task-N-report.md for what was tried.
    Open findings (verbatim):
    - [finding]
    Fix them, re-run the covering tests, commit, and append `## Fix Round R` to the report file.
```
