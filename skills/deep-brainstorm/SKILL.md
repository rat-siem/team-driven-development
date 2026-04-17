---
name: deep-brainstorm
description: Rigorous variant of brainstorming for vague or high-stakes requirements. Runs Distill/Challenge/Harden phases, gates on a 10-item checklist with dynamic additions, validates via subagent review before user approval.
---

# Deep Brainstorm

Forge a vague idea into a specified design through three phases — Distill, Challenge, Harden. Produce an extended spec with Decision Log and Unresolved Items, validate via fresh-eyes subagent, hand off to `writing-plans`.

Unlike `brainstorming`: stronger pushback, Claude-surfaced concerns, external review instead of self-review. Use for vague or high-stakes requirements, or when decision reasoning must survive into the spec.

**Announce at start:** "I'm using deep-brainstorm to run Distill/Challenge/Harden phases and produce an extended spec."

<HARD-GATE>
No implementation skill, code, or scaffolding until user approves the spec. No phase advancement until owned items are `confirmed`/`N/A`. No spec file until all ten base items resolved AND design approved.
</HARD-GATE>

## Checklist

Create a task for each item and complete in order:

1. **Explore context** — related files, docs, recent commits.
2. **Phase 1 Distill** — restate, surface ambiguity, resolve Purpose / Success criteria / Scope / Users.
3. **Phase 2 Challenge** — counter-proposals, stress-test, resolve Alternatives / Assumptions / Constraints.
4. **Phase 3 Harden** — Risks / Security / NFR + Surfaced Concerns.
5. **Present design** — section-by-section user approval.
6. **Write extended spec** — `docs/team-dd/specs/YYYY-MM-DD-<topic>-design.md`, commit.
7. **Light self-review** — placeholders + obvious contradictions (~30s).
8. **Subagent review** — dispatch with `prompts/reviewer.md`; revise on `CHANGES_REQUESTED`, max 2 rounds.
9. **User approves spec**.
10. **Invoke `writing-plans`**.

## Process Flow

```dot
digraph deep_brainstorm {
    "Explore context" [shape=box];
    "Phase 1: Distill" [shape=box];
    "Distill gate: items 1-4 confirmed?" [shape=diamond];
    "Phase 2: Challenge" [shape=box];
    "Challenge gate: items 5-7 confirmed?" [shape=diamond];
    "Phase 3: Harden" [shape=box];
    "Harden gate: items 8-10 confirmed?" [shape=diamond];
    "Present design" [shape=box];
    "User approves design?" [shape=diamond];
    "Write extended spec" [shape=box];
    "Light self-review" [shape=box];
    "Subagent review" [shape=box];
    "Review verdict?" [shape=diamond];
    "Revise spec" [shape=box];
    "User approves spec?" [shape=diamond];
    "Invoke writing-plans" [shape=doublecircle];

    "Explore context" -> "Phase 1: Distill";
    "Phase 1: Distill" -> "Distill gate: items 1-4 confirmed?";
    "Distill gate: items 1-4 confirmed?" -> "Phase 1: Distill" [label="no"];
    "Distill gate: items 1-4 confirmed?" -> "Phase 2: Challenge" [label="yes"];
    "Phase 2: Challenge" -> "Challenge gate: items 5-7 confirmed?";
    "Challenge gate: items 5-7 confirmed?" -> "Phase 2: Challenge" [label="no"];
    "Challenge gate: items 5-7 confirmed?" -> "Phase 3: Harden" [label="yes"];
    "Phase 3: Harden" -> "Harden gate: items 8-10 confirmed?";
    "Harden gate: items 8-10 confirmed?" -> "Phase 3: Harden" [label="no"];
    "Harden gate: items 8-10 confirmed?" -> "Present design" [label="yes"];
    "Present design" -> "User approves design?";
    "User approves design?" -> "Present design" [label="revise"];
    "User approves design?" -> "Write extended spec" [label="yes"];
    "Write extended spec" -> "Light self-review";
    "Light self-review" -> "Subagent review";
    "Subagent review" -> "Review verdict?";
    "Review verdict?" -> "Revise spec" [label="CHANGES_REQUESTED (≤2 rounds)"];
    "Revise spec" -> "Subagent review";
    "Review verdict?" -> "User approves spec?" [label="PASS"];
    "Review verdict?" -> "User approves spec?" [label="2 rounds failed"];
    "User approves spec?" -> "Revise spec" [label="changes"];
    "User approves spec?" -> "Invoke writing-plans" [label="approved"];
}
```

<!-- SECTIONS BELOW ARE ADDED IN LATER TASKS -->