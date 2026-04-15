# Design: Token Consumption Reduction

**Date**: 2026-04-16
**Status**: Approved

## Problem

The team-driven-development plugin dispatches multiple subagents (Worker, Reviewer, Architect) with full prompt context per task. In Full Mode with N tasks, the total token overhead scales linearly: each task sends agent definitions, dispatch prompts, Domain Guidelines, Sprint Contracts, and codebase context to both Worker and Reviewer. This results in high API costs without proportional quality gains — much of the dispatched text is redundant, verbose, or implicit knowledge the model already has.

## Goal

Reduce total token consumption by 30-50% across the plugin without degrading output quality. Quality priority order: Implementation quality (Worker) > Review accuracy (Reviewer) > Lead judgment.

## Approach

Two-phase strategy: prompt compression first (low risk, certain gains), then redundancy elimination (moderate risk, cumulative gains in multi-task plans).

---

## Phase 1: Prompt Compression

Rewrite all prompt files to convey the same information in fewer tokens. No information is removed — only the encoding changes.

### Target Files

| File | Current Size | Role | Frequency |
|------|-------------|------|-----------|
| `skills/team-driven-development/SKILL.md` | 30.9 KB / 761 lines | Lead context | Every invocation |
| `prompts/worker-prompt.md` | 3.8 KB / 122 lines | Worker dispatch | Per task |
| `prompts/reviewer-prompt.md` | 4.0 KB / 133 lines | Reviewer dispatch | Per task |
| `prompts/architect-prompt.md` | 2.2 KB / 71 lines | Architect dispatch | Rare |
| `agents/worker.md` | 2.1 KB / 50 lines | Worker agent def | Per task |
| `agents/reviewer.md` | 2.7 KB / 86 lines | Reviewer agent def | Per task |
| `agents/architect.md` | 1.9 KB / 52 lines | Architect agent def | Rare |

### Compression Techniques

1. **Prose → structured format**: Convert paragraph explanations to bullet lists and tables. Same information, 30-50% fewer tokens.

2. **Example minimization**: Keep at most one clear example per rule. Remove redundant or illustrative-only examples.

3. **Implicit knowledge removal**: Delete instructions for general best practices the LLM already follows (e.g., "write clear commit messages", "use descriptive variable names"). Keep only plugin-specific rules.

4. **SKILL.md compression**: The largest single file (30.9 KB). Apply all three techniques above. The file cannot be split for lazy loading (Claude Code loads skills as a single unit), so compression of the text itself is the lever.

### Reduction Targets

| File | Target Reduction |
|------|-----------------|
| `SKILL.md` | ≥ 25% |
| Worker dispatch total (prompt + agent def) | ≥ 30% |
| Reviewer dispatch total (prompt + agent def) | ≥ 30% |
| Architect dispatch total (prompt + agent def) | ≥ 25% |

---

## Phase 2: Redundancy Elimination

Reduce or eliminate information that is sent repeatedly across task dispatches.

### 2-1. Remove Domain Guidelines from Reviewer Prompts

**Current**: Domain Guidelines files are pasted into both Worker and Reviewer prompts for every task touching that domain.

**Change**: Remove Guidelines from Reviewer dispatch. Rationale: the Reviewer validates against the Sprint Contract, not against raw Guidelines. The Lead already incorporates Guidelines into Sprint Contract generation (Phase A-5). Making the Reviewer re-read Guidelines is redundant.

**Safeguard**: Add explicit instruction in SKILL.md's Sprint Contract generation section: "Incorporate all applicable Domain Guidelines into the Sprint Contract's acceptance criteria. The Reviewer does not receive Guidelines separately."

### 2-2. Sprint Contract Template Separation

**Current**: The Lead generates a full Sprint Contract per task, including boilerplate structure (section headings, common rules) and task-specific criteria.

**Change**: Extract the common Sprint Contract structure into a template (`templates/sprint-contract-template.md`). The Lead generates only the task-specific sections (acceptance criteria, test expectations, file scope). The dispatch prompt references the template and appends the task-specific delta.

**Benefit**: Reduces Lead's generation overhead per contract and reduces the dispatched contract size by removing repeated boilerplate.

### 2-3. Codebase Context Dispatch Guidelines

**Current**: The Lead extracts codebase context and sends full file contents to Workers in the dispatch prompt.

**Change**: Add explicit guidelines to SKILL.md for context dispatch:
- Send full content only for files the Worker must modify.
- For reference files (files the Worker may need to read but won't modify), send only the file path and a one-line description. The Worker can read them independently.
- Maximum context budget: suggest ≤ 2 KB of pre-sent file content per task (excluding the files to be modified).

**Benefit**: Workers have file-reading capability via the Read tool. Pre-sending reference file contents wastes tokens on information the Worker can fetch on demand.

---

## Quality Safeguards

1. **Token count measurement**: Record word count (`wc -w`) before and after each file change. Track in the PR description.

2. **Information completeness audit**: For each compressed file, enumerate the rules/instructions before and after. Verify no rules were dropped.

3. **Phase 2 Sprint Contract coverage**: After implementing 2-1, verify that the Sprint Contract generation instructions explicitly reference Domain Guidelines incorporation.

## Out of Scope

- Model selection optimization (effort scoring for Reviewers, expanded Lite Mode triggers)
- Superpowers skill prompts (brainstorming, writing-plans, TDD, etc.)
- Execution flow changes (review round limits, parallel dispatch strategies)
- Prompt caching at the API level (infrastructure concern, not plugin concern)

## Implementation Order

```
Phase 1 (Prompt Compression)
  1-1. SKILL.md compression
  1-2. worker-prompt.md + worker.md compression
  1-3. reviewer-prompt.md + reviewer.md compression
  1-4. architect-prompt.md + architect.md compression

Phase 2 (Redundancy Elimination)
  2-1. Remove Domain Guidelines from Reviewer dispatch
  2-2. Sprint Contract template separation
  2-3. Codebase Context dispatch guidelines in SKILL.md
```

Phase 1 tasks are independent and can be parallelized. Phase 2 tasks depend on Phase 1 completion (compressed prompts are the baseline for redundancy changes).
