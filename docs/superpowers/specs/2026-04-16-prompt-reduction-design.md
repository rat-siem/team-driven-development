# Prompt Reduction Design

## Overview

Reduce token consumption across all skill and agent prompts by eliminating redundancy, converting prohibition lists to positive directives, and routing dispatch prompts through typed subagents. Core behavior (plan → implement → review cycle) is unchanged.

## Motivation

- Dispatch prompts duplicate role definitions already present in `agents/*.md`
- Prohibition lists ("Never do X") are redundant when positive rules already bound behavior
- `subagent_type: "general-purpose"` prevents automatic loading of agent definitions, forcing full role re-definition on every dispatch
- Solo-review already uses typed subagent but still carries a full role definition in the prompt body

## Design

### Strategy: One Change That Eliminates Multiple Instructions

The single most impactful change is switching dispatch prompts from `subagent_type: "general-purpose"` to the typed agent variants. When the correct subagent type is used, the agent's system prompt (from `agents/*.md`) is loaded automatically. The dispatch prompt (user message) then needs only task-specific context.

This one change makes the following sections redundant in every dispatch prompt:
- "You are a Worker / Reviewer / Architect..."
- Your Job / steps
- Self-Review Checklist
- Escalation rules
- Report Format / Design Brief Format

### dispatch prompts (Primary Target)

**`prompts/worker-prompt.md`**: Switch to `team-driven-development:worker`. Remove all role definition. Retain: Task, Sprint Contract, Design Brief (if any), Domain Guidelines (if any), Codebase Context, one-line clarification invitation.

**`prompts/reviewer-prompt.md`**: Switch to `team-driven-development:reviewer`. Remove all role definition. Retain: Review Profile, Sprint Contract, Changes (diff), Files Changed.

**`prompts/architect-prompt.md`**: Switch to `team-driven-development:architect`. Remove all role definition. Retain: Task, Codebase Context, Related Tasks, Why You're Needed.

Estimated reduction: ~170 lines → ~50 lines (-70%).

### `agents/*.md` (No Changes)

Already minimal. These files are the single source of truth for each role.

### `skills/team-driven-development/SKILL.md`

**Delete:** `Red Flags` section (~17 lines). All preventive rules are already implied by the positive algorithm. Exception: review-skip protection (see below).

**Delete:** `Integration` section (~7 lines). Non-operational; users can navigate to skills themselves.

**Add to Phase B header:**
```
**Review is mandatory.** Every task — Full and Lite — dispatches a Reviewer before cherry-pick. No exceptions.
```

**Add to Lite Mode step 3:**
```
Dispatch Reviewer on full diff. **Mandatory — never skip.**
```

Review-skip is retained as a strong positive directive in two locations (Full and Lite paths) because it is a confirmed recurring failure pattern in harness-style plugins, not a preventive guess.

### `skills/quick-plan/SKILL.md`

**Delete:** `Red Flags` section (~10 lines). HARD-GATE and main checklist already prohibit these behaviors.

**Trim:** `Clarification Logic` section. Remove "What does NOT need a question" list — the inverse of "What counts as genuinely ambiguous" is self-evident. Keep only the positive definition.

### `skills/solo-review/SKILL.md`

**Dispatch prompt cleanup:** Solo-review already uses `team-driven-development:reviewer` correctly. Remove the role definition ("You are a Reviewer agent..."), `Your Job` steps, `Severity Rules` table, and `Code Quality Scan` step from the dispatch prompt body — all are in `agents/reviewer.md`.

**Delete:** `Red Flags` section (~6 lines). Main rules and "report-only" framing already cover these.

### Error Handling

No error handling changes needed. The agents themselves define escalation behavior (`BLOCKED`, `NEEDS_CONTEXT`). This design does not change those definitions.

### Testing Strategy

- Manually dispatch a Worker via the updated prompt and verify it produces a compliant report
- Manually dispatch a Reviewer and verify it produces a verdict
- Verify Lite Mode still shows "Mandatory — never skip" in Lead context during execution
- No automated tests (skill prompts are not programmatically testable)

## File Changes

| File | Change |
|------|--------|
| `skills/team-driven-development/prompts/worker-prompt.md` | Rewrite — remove role definition, switch subagent_type |
| `skills/team-driven-development/prompts/reviewer-prompt.md` | Rewrite — remove role definition, switch subagent_type |
| `skills/team-driven-development/prompts/architect-prompt.md` | Rewrite — remove role definition, switch subagent_type |
| `skills/team-driven-development/SKILL.md` | Delete Red Flags + Integration; add Review is mandatory |
| `skills/quick-plan/SKILL.md` | Delete Red Flags; trim Clarification Logic |
| `skills/solo-review/SKILL.md` | Remove role definition from dispatch prompt; delete Red Flags |
| `agents/*.md` | Not modified |
| `templates/sprint-contract-template.md` | Not modified |
