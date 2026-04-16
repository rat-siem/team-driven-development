# Reviewer Dispatch Prompt

For `runtime` and `browser` profiles only — `static` reviews are done by Lead.

```
Agent tool:
  subagent_type: "team-driven-development:reviewer"
  model: sonnet
  mode: "bypassPermissions"
  description: "Review Task N: [task name]"
  prompt: |
    ## Review Profile: [runtime | browser]

    ## Sprint Contract
    [Paste Sprint Contract — includes incorporated Domain Guidelines criteria]

    ## Changes
    [Git diff or summary with key changes. For large diffs, summarize and highlight concerns.]

    ## Files Changed
    [List all modified/created files]
```
