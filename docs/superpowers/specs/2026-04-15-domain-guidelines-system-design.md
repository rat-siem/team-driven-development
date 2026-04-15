# Domain Guidelines System

## Problem

When agents implement tasks without domain-specific constraints (design systems, API conventions, writing style guides, etc.), output quality varies significantly. A generalist Worker produces inconsistent results across specialized domains — inconsistent spacing, mismatched colors, divergent API patterns — because it lacks explicit constraints to follow.

This is not limited to UI/UX. The same problem applies to backend engineering, technical writing, testing strategy, and any domain where consistency matters.

## Solution

Add a **Domain Guidelines System** that automatically detects when a project lacks guidelines for relevant domains, generates drafts from existing code, and integrates approved guidelines into Sprint Contracts so Workers and Reviewers enforce them.

**Key principle:** No new roles. Domain knowledge is externalized into guideline files (project assets), not embedded in specialized agent prompts.

## Architecture

### Guideline Files

Stored in the project's `guidelines/` directory:

```
project-root/
  guidelines/
    frontend.md
    backend.md
    writing.md
    testing.md
    ...
```

Each file uses the following format:

```markdown
---
domain: frontend
version: 1
last_updated: 2026-04-15
---

# Frontend Guidelines

## Color Palette
...

## Spacing System
...
```

### Domain Detection Table

Directory-name-based pattern matching (file extensions are ambiguous across domains):

| Pattern | Domain |
|---|---|
| `components/`, `pages/`, `layouts/`, `styles/`, `*.css` | frontend |
| `routes/`, `api/`, `controllers/`, `services/`, `models/` | backend |
| `docs/`, `content/`, `*.md` | writing |
| `__tests__/`, `tests/`, `*.test.*`, `*.spec.*` | testing |

**Fallback:** When file paths don't match any pattern, the Lead determines the domain from task content and file analysis.

### Custom Domains

Users can add custom domains by placing files directly in `guidelines/`. The system detects any file in that directory and incorporates it into Sprint Contracts, regardless of whether it matches a built-in domain template.

## Phase 0: Guideline Check

A new phase inserted before Phase A (Pre-delegate) in the execution flow:

```
Phase 0: Guideline Check (new)
  ↓
Phase A: Pre-delegate (existing)
  ↓
Phase B: Delegate (existing)
  ↓
Phase C: Post-delegate (existing)
```

### Trigger Condition

Phase 0 executes only when **at least one** of the following is true for a detected domain:

- The plan includes tasks that **create new files** in that domain
- The plan includes tasks that **modify 3 or more files** in that domain

If neither condition is met, Phase 0 is skipped entirely. Small bug fixes and minor edits proceed without interruption.

### Steps

**0-1: Domain Detection**
Collect all file paths from all tasks in the plan. Match against the detection table. Use Lead fallback for unmatched paths.

**0-2: Guideline Existence Check**
For each detected domain, check if `guidelines/{domain}.md` exists.
- All exist → skip to Phase A
- Any missing → proceed to 0-3

**0-3: Draft Generation**
For each missing domain:
- **Existing code available:** Lead analyzes current codebase to extract patterns (colors in use, spacing values, API response formats, naming conventions, etc.) and generates a populated draft.
- **New project (no existing code):** Lead generates a scaffold template with section headings and placeholder comments for the user to fill in.

Write drafts to `guidelines/{domain}.md`.

**0-4: User Approval Gate**
Present generated guidelines to the user for review:
> "Generated the following guidelines. Please review and edit as needed."

- Approved → proceed to Phase A
- Changes requested → revise and re-present

### Applies to Both Modes

Phase 0 runs in both Lite Mode and Full Mode. Guideline consistency matters regardless of plan complexity.

## Sprint Contract Integration

### Guidelines Section

Sprint Contracts gain a new `Guidelines` section:

```markdown
## Sprint Contract: Task 3 - Create user profile page

### Success Criteria
- ...

### Non-Goals
- ...

### Guidelines
- frontend: guidelines/frontend.md
- writing: guidelines/writing.md

### Reviewer Profile: browser
```

### Worker Dispatch

When the Lead dispatches a Worker, it reads the content of referenced guideline files and includes them in the dispatch prompt alongside the Sprint Contract. The Worker treats guidelines as implementation constraints to follow.

### Reviewer Evaluation

Reviewers receive guidelines as additional evaluation criteria:

```markdown
### Sprint Contract Checklist
- [existing success criteria]
- Guidelines compliance: frontend guidelines followed (spacing, colors, component conventions)
- Guidelines compliance: writing guidelines followed (tone, terminology)
```

Guideline violations are reported as findings with severity classification:
- Systematic violations (e.g., wrong color palette throughout) → major
- Isolated deviations (e.g., one inconsistent spacing value) → minor

### Tasks Without Guidelines

Two cases where tasks have no guidelines in their Sprint Contract:

1. **Guidelines file exists but task is small:** Phase 0 was skipped (trigger condition not met), yet `guidelines/{domain}.md` exists. In this case, the Lead still includes the guidelines in the Sprint Contract. Phase 0 controls *generation*, not *usage*. Existing guidelines are always referenced.
2. **No guidelines file exists and Phase 0 was skipped:** The task proceeds with a traditional Sprint Contract and no guidelines section.

## Guideline Templates

The plugin ships with four default domain templates in `templates/guidelines/`:

### frontend.md

```markdown
---
domain: frontend
version: 1
last_updated: YYYY-MM-DD
---

# Frontend Guidelines

## Color Palette
<!-- Define primary, secondary, accent, error, warning, success colors -->

## Spacing System
<!-- Define base unit and scale -->

## Component Conventions
<!-- Naming, structure, prop patterns -->
```

### backend.md

```markdown
---
domain: backend
version: 1
last_updated: YYYY-MM-DD
---

# Backend Guidelines

## API Design
<!-- URL structure, versioning, request/response format -->

## Error Handling
<!-- Error response format, status codes, error categories -->

## Database Conventions
<!-- Naming, indexing strategy, migration patterns -->
```

### writing.md

```markdown
---
domain: writing
version: 1
last_updated: YYYY-MM-DD
---

# Writing Guidelines

## Tone & Voice
<!-- Formal/informal, audience, perspective -->

## Terminology
<!-- Project-specific terms and their definitions -->
```

### testing.md

```markdown
---
domain: testing
version: 1
last_updated: YYYY-MM-DD
---

# Testing Guidelines

## Test Structure
<!-- Naming conventions, organization, setup/teardown patterns -->

## Test Types
<!-- Unit, integration, e2e — when to use each -->
```

## Changes to Existing Files

| File | Change |
|---|---|
| `SKILL.md` | Add Phase 0 description, domain detection table, Sprint Contract Guidelines section |
| `prompts/worker-prompt.md` | Add instruction to follow guidelines when present in Sprint Contract |
| `prompts/reviewer-prompt.md` | Add guidelines compliance as evaluation criteria |
| `sprint-contract-template.md` | Add Guidelines section |
| `templates/guidelines/*.md` | New files (4 templates) |

## What Does NOT Change

- **Role composition:** Lead / Worker / Reviewer / Architect — no new roles
- **Lite Mode / Full Mode selection:** Triage logic unchanged
- **Effort scoring:** Independent from Phase 0 trigger conditions
- **Agent definition files (`agents/*.md`):** Unchanged
