---
name: team-plan
description: Team-driven-development plan writer. Converts a spec (with Sprint Contract) into a token-optimized implementation plan for Lead/Worker/Reviewer agents.
---

# Team Plan

Write a team-driven-development implementation plan from a spec. Replaces `superpowers:writing-plans` inside this plugin. Plans are hybrid-density (execution artifacts inline, rationale referenced) with a common Sprint Contract plus per-task deltas.

**Announce at start:** "I'm using team-plan to generate an implementation plan from the spec."

<HARD-GATE>
Do NOT write any implementation code or invoke any execution skill until the user has approved the plan. If the spec lacks a `## Sprint Contract` section, stop and emit the guidance message in Error Handling — do not create a partial plan.
</HARD-GATE>

## Checklist

1. **Read spec** — open the file at the provided path. Fail if missing.
2. **Validate Sprint Contract** — require `## Sprint Contract` with a `Profile` of `static`, `runtime`, or `browser`. Fail fast if absent or invalid.
3. **Derive target path** — topic = spec filename with the leading `YYYY-MM-DD-` prefix and trailing `-design` suffix removed. Target = `docs/team-dd/plans/YYYY-MM-DD-<topic>.md`.
4. **Generate plan** — write header, common Sprint Contract, File Structure, tasks.
5. **Self-review** — run mechanical checks; fix findings inline.
6. **Write file** — save to target path, report path to caller.
7. **User confirms plan** — wait for approval. Revise on request.
8. **Propose execution** — offer `team-driven-development` handoff.

## Process Flow

```dot
digraph team_plan {
    "Read spec" [shape=box];
    "Sprint Contract valid?" [shape=diamond];
    "Emit guidance and stop" [shape=doublecircle];
    "Derive target path" [shape=box];
    "Generate plan" [shape=box];
    "Self-review" [shape=box];
    "Issues found?" [shape=diamond];
    "Fix inline" [shape=box];
    "Write file" [shape=box];
    "User approves plan?" [shape=diamond];
    "Propose execution" [shape=doublecircle];

    "Read spec" -> "Sprint Contract valid?";
    "Sprint Contract valid?" -> "Emit guidance and stop" [label="no"];
    "Sprint Contract valid?" -> "Derive target path" [label="yes"];
    "Derive target path" -> "Generate plan";
    "Generate plan" -> "Self-review";
    "Self-review" -> "Issues found?";
    "Issues found?" -> "Fix inline" [label="yes"];
    "Fix inline" -> "Self-review";
    "Issues found?" -> "Write file" [label="no"];
    "Write file" -> "User approves plan?";
    "User approves plan?" -> "Generate plan" [label="revise"];
    "User approves plan?" -> "Propose execution" [label="yes"];
}
```
