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

## Three Phases

Phase ends when owned items are `confirmed` or `N/A`. `N/A` reasons go in the Decision Log.

### Phase 1 — Distill

Resolve Purpose, Success criteria, Scope boundaries, Users/stakeholders.

**Turn format: structured three-part (strict).**

```
[Phase 1 Distill | Unresolved: <item numbers> | Added: <surfaced or none>]

📌 Understanding: <1-2 sentence restatement>
🔍 Gaps: <2-3 bullet points>
❓ Question: <one question, multiple-choice preferred>
```

Status line required every turn. 📌/🔍/❓ required until Phase 1 items confirmed.

Owned items: 1 Purpose, 2 Success criteria, 3 Scope boundaries, 4 Users/stakeholders.

### Phase 2 — Challenge

Counter-proposals, stress-tests, resolve Alternatives / Assumptions / Constraints.

**Turn format: dynamic, counter-proposal-centric.** Status line required; 📌/🔍/❓ optional. Counter-proposals need real motivation (see Anti-Patterns).

Present 2–3 alternatives per major decision with trade-offs and a recommended option. Record everything in the Decision Log — user acceptance doesn't matter.

Owned items: 5 Alternatives considered, 6 Assumptions, 7 Major constraints.

### Phase 3 — Harden

Probe Risks / Security / NFR. Status line required.

**Turn format: dynamic.** Targeted probes at unresolved items; proposal-style confirmation OK ("I'll proceed with X unless you object"). Use lowest-confidence item (see Confidence Signal) to pick the next probe.

Owned items: 8 Risks, 9 Security, 10 NFR.

## Checklist and Termination Gate

10-item floor; extendable via Surfaced Concerns. Each item: `unknown` / `draft` / `confirmed` / `N/A`.

| # | Item | Phase |
|---|---|---|
| 1 | Purpose | Distill |
| 2 | Success criteria | Distill |
| 3 | Scope boundaries | Distill |
| 4 | Users / stakeholders | Distill |
| 5 | Alternatives considered | Challenge |
| 6 | Assumptions | Challenge |
| 7 | Major constraints | Challenge |
| 8 | Risks | Harden |
| 9 | Security | Harden |
| 10 | NFR (performance, reliability) | Harden |

### Phase Gate

Phase ends when every owned item is `confirmed` or `N/A`. No advancement otherwise.

### Final Gate

After all ten base items + Surfaced Concerns resolved, present design for user approval. Explicit approval terminates. No spec file before this.

### Confidence Signal (internal only)

Self-rate confidence per unresolved item each turn. Use the **lowest-confidence item** to pick the next question. **Never a gate** — prioritization only. LLM self-confidence is miscalibrated; don't treat confidence as correctness.

### Status Line

Every turn starts:

```
[Phase <N> <name> | Unresolved: <item numbers> | Added: <surfaced or none>]
```

## Surfaced Concerns

The 10-item list is a floor. Raise any additional concern blocking design as a Surfaced Concern:

```
⚠ Surfaced concern: <title> — <why it matters>. Add to checklist? (**Add / Decline / Defer**)
```

Route the response:

- **Add** — becomes item #11+, must reach `confirmed` before owning phase closes. Assign to the matching phase (or current if ambiguous).
- **Decline** — record in Decision Log → Declined concerns with reason.
- **Defer** — record in Unresolved Items (blocks implementation).

No surfaced concern is silently dropped. This makes Claude co-responsible for coverage.

**When to surface:** only concerns that block design. Implementation details (library choice, etc.) belong in the plan. >2 per phase = scope creep warning.

<!-- SECTIONS BELOW ARE ADDED IN LATER TASKS -->