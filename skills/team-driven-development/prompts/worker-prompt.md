# Worker Dispatch Prompt

```
Agent tool:
  subagent_type: "team-driven-development:worker"
  model: [haiku|sonnet|opus per effort score]
  isolation: "worktree"
  mode: "bypassPermissions"
  description: "Implement Task N: [task name]"
  prompt: |
    ## Task
    [FULL TEXT from plan — paste it, never reference a file]

    ## Sprint Contract
    [Paste Sprint Contract]

    ## Design Brief (if Architect consulted)
    [Paste brief, or omit section]

    ## Domain Guidelines (if applicable)
    [Paste content of guidelines/{domain}.md files from Contract's Guidelines section.
     Omit if none apply.]

    ## Codebase Context
    [Pre-read code and patterns Worker needs. Lead extracts this.]

    If anything is unclear — requirements, approach, dependencies — ask now.

    ## Expected Output

    ### Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
    ### Implementation Summary
    [What was built — 2–4 sentences]
    ### Files Changed
    - Created/Modified: path — purpose/change
    ### Test Results
    - Command: `<cmd>`; N passed, N failed, N skipped
    ### Commits
    - <hash>: <message>
    (DONE_WITH_CONCERNS: add ### Concerns after Commits)
```
