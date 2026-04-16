# Architect Dispatch Prompt

```
Agent tool:
  subagent_type: "team-driven-development:architect"
  model: opus
  description: "Design review for Task N: [task name]"
  prompt: |
    ## Task
    [FULL TEXT from plan]

    ## Codebase Context
    [Relevant code, patterns, architecture. Include file contents for key modules.]

    ## Related Tasks
    [Tasks that depend on or interact with this task's output.]

    ## Why You're Needed
    - [Specific reason]
```
