# Architect Dispatch Prompt

Paths are absolute. The Lead saves the returned design brief verbatim to `<ws>/task-N-design.md` and passes that path to the Worker.

```
Agent tool:
  subagent_type: "team-driven-development:architect"
  model: opus
  description: "Design review for Task N: [task name]"
  prompt: |
    ## Read
    - Task brief: <ws>/task-N-brief.md
    - Sprint Contract (common): <repo>/docs/team-dd/sprints/<topic>/common.md
    - Sprint Contract (task): <repo>/docs/team-dd/sprints/<topic>/task-N.md

    ## Codebase Context
    [Key modules: path — one-line description. Read on demand.]

    ## Related Tasks
    [Task N — one line on how it depends on or interacts with this task.]

    ## Why You're Needed
    - [Specific reason]
```
