# Design: Triage Gate + Lite Mode

**Date**: 2026-04-15
**Status**: Approved

## Problem

The team-driven-development skill applies the full orchestration process (Sprint Contracts, Worker dispatch, per-task review) regardless of plan complexity. For simple plans (1-2 tasks, few files), this creates unnecessary overhead. The skill should detect simple plans early and suggest a lightweight execution mode to the user.

## Decision

Add a **Triage Gate** (Phase A-0) at the start of the process. When the plan scores below a threshold, the Lead proposes Lite Mode to the user. The user always has the option to use the full process instead.

## Triage: Quick Score

Calculated immediately after reading the plan, using only surface-level metrics:

| Factor | Condition | Score |
|--------|-----------|-------|
| Task count | 1-2 tasks | 0 |
| Task count | 3-4 tasks | +1 |
| Task count | 5+ tasks | +2 |
| Total files | ≤ 3 files across all tasks | 0 |
| Total files | 4-6 files | +1 |
| Total files | 7+ files | +2 |
| Domain spread | Single directory/module | 0 |
| Domain spread | Multiple directories | +1 |
| Design keywords | "architecture", "migration", "security", "API design" in any task | +1 |

**Threshold: Quick Score ≤ 1 → propose Lite Mode**

## Lite Mode vs Full Mode

| Aspect | Full Mode | Lite Mode |
|--------|-----------|-----------|
| Implementer | Worker subagent | Lead directly |
| Isolation | Worktree per task | None (on current branch) |
| Sprint Contract | Generated per task | None (Plan steps used directly) |
| Review | Per-task, static/runtime/browser | **Reviewer subagent reviews full diff once after all tasks complete** |
| Architect | Summoned when needed | None |
| Effort Scoring | Performed | Skipped |
| Completion Report | Detailed table | Brief summary (task list + commit list) |

## Lite Mode Flow

```
Phase A-0: Triage
  ├─ Quick Score ≤ 1 → Propose Lite Mode to user
  │   ├─ User accepts → Lite Mode
  │   └─ User declines → Full Mode (Phase A-1 onwards)
  └─ Quick Score > 1 → Full Mode (no proposal)

Lite Mode Execution:
  1. Execute tasks sequentially (Lead implements directly)
  2. Follow Plan steps as-is (TDD maintained)
  3. Commit after each task
  4. After all tasks complete → dispatch Reviewer subagent with full diff
  5. REQUEST_CHANGES → Lead fixes, re-review (max 2 rounds)
  6. APPROVE → output brief summary
```

## User-Facing Proposal Message

When Lite Mode is suggested:

> **This plan has [N] tasks touching [M] files — lightweight enough for direct execution. I'll implement the tasks directly and have a Reviewer check the final diff. Use Lite Mode?**
>
> - **Yes** — Direct execution + single review at the end
> - **No** — Full team process (Workers, Sprint Contracts, per-task review)

## Changes to SKILL.md

1. **When to Use section**: Remove "Don't use when: Plan has only 1-2 simple tasks (just do them directly)". Replace with: "Simple plans automatically trigger a Lite Mode suggestion."
2. **Process flow**: Insert Phase A-0 (Triage) before Phase A-1.
3. **New section**: "Lite Mode" documenting the lightweight flow.
4. **Dot graph**: Add Triage branching at the top of the process flow.

## What Does NOT Change

- Full Mode process (Phase A-1 through C-3) remains identical
- Worker, Reviewer, Architect agent definitions unchanged
- Sprint Contract template unchanged
- Prompt templates unchanged
- Reviewer is always a separate subagent (even in Lite Mode)
