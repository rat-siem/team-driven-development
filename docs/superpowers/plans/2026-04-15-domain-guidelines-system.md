# Domain Guidelines System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Domain Guidelines System that detects missing domain-specific guidelines, generates drafts from existing code, and integrates approved guidelines into Sprint Contracts for Workers and Reviewers.

**Architecture:** A new Phase 0 (Guideline Check) runs before triage in both Lite and Full modes. It uses directory-based pattern matching to detect relevant domains, checks for guideline files in `guidelines/`, and generates drafts when missing. Approved guidelines are injected into Sprint Contracts and Worker/Reviewer prompts.

**Tech Stack:** Markdown templates, shell scripting (no external dependencies)

---

### Task 1: Create guideline templates

**Files:**
- Create: `templates/guidelines/frontend.md`
- Create: `templates/guidelines/backend.md`
- Create: `templates/guidelines/writing.md`
- Create: `templates/guidelines/testing.md`

- [ ] **Step 1: Create templates directory**

Run: `mkdir -p templates/guidelines`

- [ ] **Step 2: Create frontend template**

Create `templates/guidelines/frontend.md`:

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
<!-- Define base unit and scale (e.g., 4px base: 4, 8, 12, 16, 24, 32, 48, 64) -->

## Typography
<!-- Define font families, sizes, weights for headings, body, captions -->

## Component Conventions
<!-- Naming patterns, file structure, prop conventions -->

## Accessibility
<!-- Minimum requirements: contrast ratio, keyboard navigation, aria labels, focus management -->
```

- [ ] **Step 3: Create backend template**

Create `templates/guidelines/backend.md`:

```markdown
---
domain: backend
version: 1
last_updated: YYYY-MM-DD
---

# Backend Guidelines

## API Design
<!-- URL structure, versioning, request/response format, pagination -->

## Error Handling
<!-- Error response format, status codes, error categories, logging -->

## Database Conventions
<!-- Naming (tables, columns), indexing strategy, migration patterns -->

## Authentication & Authorization
<!-- Auth patterns, token handling, permission model, session management -->
```

- [ ] **Step 4: Create writing template**

Create `templates/guidelines/writing.md`:

```markdown
---
domain: writing
version: 1
last_updated: YYYY-MM-DD
---

# Writing Guidelines

## Tone & Voice
<!-- Formal/informal, audience, perspective (first/second/third person) -->

## Terminology
<!-- Project-specific terms, abbreviations, and their definitions -->

## Structure
<!-- Document structure, heading conventions, section length guidelines -->
```

- [ ] **Step 5: Create testing template**

Create `templates/guidelines/testing.md`:

```markdown
---
domain: testing
version: 1
last_updated: YYYY-MM-DD
---

# Testing Guidelines

## Coverage Requirements
<!-- Minimum coverage targets, what must be tested, what can be skipped -->

## Test Structure
<!-- Naming conventions, file organization, setup/teardown patterns -->

## Test Types
<!-- Unit, integration, e2e — when to use each, boundaries between them -->
```

- [ ] **Step 6: Commit**

```bash
git add templates/guidelines/
git commit -m "feat: add domain guideline templates for frontend, backend, writing, testing"
```

---

### Task 2: Add Phase 0 to SKILL.md

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

This is the largest task. It adds the Phase 0 section, updates the process diagram, and modifies Lite Mode to reference guidelines.

- [ ] **Step 1: Add Phase 0 node to the Mermaid process diagram**

In `SKILL.md`, find the process diagram (starts at line 126). Add a Phase 0 node and connect it before the triage subgraph. Insert after line 140 (after the Phase C node declaration, before `subgraph cluster_triage`):

Find:
```
    "Phase C: Post-delegate" [shape=box style=filled fillcolor=lightgreen];

    subgraph cluster_triage {
```

Replace with:
```
    "Phase C: Post-delegate" [shape=box style=filled fillcolor=lightgreen];

    subgraph cluster_phase0 {
        label="Phase 0: Guideline Check";
        "P0-1: Detect domains from file paths" [shape=box];
        "P0-2: Check guidelines/ for each domain" [shape=box];
        "P0-3: All exist?" [shape=diamond];
        "P0-4: Generate drafts from code/templates" [shape=box];
        "P0-5: User approves?" [shape=diamond];

        "P0-1: Detect domains from file paths" -> "P0-2: Check guidelines/ for each domain";
        "P0-2: Check guidelines/ for each domain" -> "P0-3: All exist?";
        "P0-3: All exist?" -> "P0-4: Generate drafts from code/templates" [label="missing"];
        "P0-4: Generate drafts from code/templates" -> "P0-5: User approves?";
        "P0-5: User approves?" -> "P0-4: Generate drafts from code/templates" [label="changes requested"];
    }

    "P0-3: All exist?" -> "Phase A-0: Triage" [label="all exist"];
    "P0-5: User approves?" -> "Phase A-0: Triage" [label="approved"];

    subgraph cluster_triage {
```

- [ ] **Step 2: Add Phase 0 section text**

Insert the following new section between the process diagram closing (line 239, the closing ` ``` `) and `## Phase A-0: Triage` (line 241):

```markdown

## Phase 0: Guideline Check

Detect domain-specific guidelines needed for the plan and ensure they exist before proceeding.

### Trigger Condition

Phase 0 runs only when at least one of the following is true for a detected domain:
- The plan includes tasks that **create new files** in that domain
- The plan includes tasks that **modify 3 or more files** in that domain

If neither condition is met, skip Phase 0 entirely and proceed to Phase A-0: Triage. Small bug fixes and minor edits proceed without interruption.

**Note:** This condition controls guideline *generation* only. If `guidelines/{domain}.md` already exists, the Lead always includes it in Sprint Contracts regardless of trigger conditions.

### Custom Domains

Users can add their own guideline files directly to the project's `guidelines/` directory (e.g., `guidelines/data-pipeline.md`). The Lead detects any file in that directory and incorporates it into Sprint Contracts for tasks touching relevant code, even if the domain is not in the built-in detection table. The Lead uses its fallback judgment to match custom domains to tasks.

### Domain Detection Table

Match task file paths against directory patterns:

| Pattern | Domain |
|---|---|
| `components/`, `pages/`, `layouts/`, `styles/`, `*.css` | frontend |
| `routes/`, `api/`, `controllers/`, `services/`, `models/` | backend |
| `docs/`, `content/`, `*.md` | writing |
| `__tests__/`, `tests/`, `*.test.*`, `*.spec.*` | testing |

**Fallback:** When file paths don't match any pattern, the Lead determines the domain from task content and file analysis.

### Steps

**0-1: Domain Detection**
Collect all file paths from all tasks in the plan. Match against the Domain Detection Table. Use Lead judgment as fallback for unmatched paths.

**0-2: Guideline Existence Check**
For each detected domain, check if `guidelines/{domain}.md` exists in the project.
- All exist → skip to Phase A-0: Triage
- Any missing → proceed to 0-3

**0-3: Draft Generation**
For each missing domain guideline:
- **Existing code available:** Analyze current codebase to extract patterns (colors, spacing values, API response formats, naming conventions, test structure, etc.) and generate a populated draft based on the template from `templates/guidelines/{domain}.md`.
- **New project (no existing code):** Copy the template from `templates/guidelines/{domain}.md` as-is for the user to fill in.

Write drafts to the project's `guidelines/{domain}.md`.

**0-4: User Approval Gate**
Present generated guidelines to the user:
> "Generated the following domain guidelines. Please review and edit as needed before I proceed."

Show the content of each generated file. Wait for user response:
- Approved → proceed to Phase A-0: Triage
- Changes requested → apply edits and re-present

### Applies to Both Modes

Phase 0 runs before triage, so it applies to both Lite Mode and Full Mode.

```

- [ ] **Step 3: Update Lite Mode section to reference guidelines**

In the Lite Mode Flow section (line 302-310), find:

```
1. **Execute tasks sequentially** — Lead implements each task directly, following Plan steps as-is. TDD is maintained.
```

Replace with:

```
1. **Execute tasks sequentially** — Lead implements each task directly, following Plan steps as-is. TDD is maintained. If `guidelines/{domain}.md` files exist for relevant domains, the Lead follows them as implementation constraints.
```

- [ ] **Step 4: Commit**

```bash
git add skills/team-driven-development/SKILL.md
git commit -m "feat: add Phase 0 (Guideline Check) to SKILL.md"
```

---

### Task 3: Add Guidelines section to Sprint Contract template

**Files:**
- Modify: `skills/team-driven-development/sprint-contract-template.md`

- [ ] **Step 1: Add Guidelines section to the template block**

In `sprint-contract-template.md`, find (lines 30-32):

```markdown
### Effort Score: [0-5]
### Model Selection: [haiku | sonnet | opus]
### Dependencies: [Task IDs this task depends on, or "none"]
```

Replace with:

```markdown
### Guidelines
- [domain]: guidelines/[domain].md
<!-- Include one line per relevant domain. Omit this section if no guidelines exist. -->

### Effort Score: [0-5]
### Model Selection: [haiku | sonnet | opus]
### Dependencies: [Task IDs this task depends on, or "none"]
```

- [ ] **Step 2: Add Guidelines generation rule**

After the "### Model Selection from Effort Score" section (line 90), add:

```markdown

### Guidelines Integration

When generating a Sprint Contract, the Lead checks for `guidelines/{domain}.md` files relevant to the task:

1. Determine which domains the task touches (using the Domain Detection Table from SKILL.md Phase 0)
2. For each domain with an existing guideline file, add it to the Guidelines section
3. If no guideline files exist for the task's domains, omit the Guidelines section entirely

The Lead reads the full content of each referenced guideline file and includes it in the Worker's dispatch prompt alongside the Sprint Contract.
```

- [ ] **Step 3: Add Guidelines to Contract QA checklist**

Find the Contract QA section (line 92-100). After line 100, add:

```markdown
6. [ ] Guidelines section references only files that exist in `guidelines/`
```

- [ ] **Step 4: Commit**

```bash
git add skills/team-driven-development/sprint-contract-template.md
git commit -m "feat: add Guidelines section to Sprint Contract template"
```

---

### Task 4: Update Worker prompt to follow guidelines

**Files:**
- Modify: `skills/team-driven-development/prompts/worker-prompt.md`

- [ ] **Step 1: Add Guidelines section to the Worker dispatch template**

In `worker-prompt.md`, find (lines 27-30):

```
    ## Codebase Context

    [Relevant existing code, patterns, imports that the Worker needs to know.
     The Lead pre-reads and extracts this — don't make the Worker search.]
```

Insert the following **before** the Codebase Context section:

```
    ## Domain Guidelines (if applicable)

    [Paste the content of each guidelines/{domain}.md file referenced in the
     Sprint Contract's Guidelines section. Omit this section if no guidelines apply.]

    These guidelines are project-approved constraints. Follow them for all
    implementation decisions in their respective domains (colors, spacing,
    API patterns, naming, test structure, etc.).

```

- [ ] **Step 2: Add guidelines to the Self-Review Checklist**

Find the "Discipline" section in the self-review checklist (lines 83-86):

```
    **Discipline:**
    - Did I avoid overbuilding (YAGNI)?
    - Did I only build what was requested?
    - Did I respect the Non-Goals in the Sprint Contract?
```

Replace with:

```
    **Discipline:**
    - Did I avoid overbuilding (YAGNI)?
    - Did I only build what was requested?
    - Did I respect the Non-Goals in the Sprint Contract?
    - Did I follow the Domain Guidelines (if provided)?
```

- [ ] **Step 3: Commit**

```bash
git add skills/team-driven-development/prompts/worker-prompt.md
git commit -m "feat: add Domain Guidelines support to Worker prompt"
```

---

### Task 5: Update Reviewer prompt to check guidelines compliance

**Files:**
- Modify: `skills/team-driven-development/prompts/reviewer-prompt.md`

- [ ] **Step 1: Add Guidelines section to the Reviewer dispatch template**

In `reviewer-prompt.md`, find (lines 28-29):

```
    ## Files Changed

    [List all files the Worker modified/created]
```

Insert the following **before** the Files Changed section:

```
    ## Domain Guidelines (if applicable)

    [Paste the content of each guidelines/{domain}.md file referenced in the
     Sprint Contract's Guidelines section. Omit this section if no guidelines apply.]

```

- [ ] **Step 2: Add Guidelines Compliance check to "Your Job" section**

Find the "### 5. Code Quality Scan" section (lines 58-64):

```
    ### 5. Code Quality Scan

    Quick scan for:
    - Security vulnerabilities (critical)
    - Broken existing functionality (major)
    - Spec mismatches (major)
    - Style/naming issues (minor — do NOT block on these)
```

Insert the following **before** the Code Quality Scan section:

```
    ### 5. Guidelines Compliance (if Domain Guidelines provided)

    Check the Worker's implementation against each relevant domain guideline:
    - Systematic violations (e.g., using wrong color palette throughout, ignoring spacing system) → major
    - Isolated deviations (e.g., one inconsistent spacing value, single naming mismatch) → minor

    Skip this section if no Domain Guidelines were provided.

```

And renumber the existing Code Quality Scan from `### 5.` to `### 6.`:

```
    ### 6. Code Quality Scan
```

- [ ] **Step 3: Commit**

```bash
git add skills/team-driven-development/prompts/reviewer-prompt.md
git commit -m "feat: add Guidelines compliance check to Reviewer prompt"
```

---

### Task 6: Update SKILL.md Phase A-5 to include guidelines in Sprint Contracts

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

- [ ] **Step 1: Add Guidelines to the Sprint Contract example in Phase A-5**

In `SKILL.md`, find the Sprint Contract example in Phase A-5 (around line 392-415):

```markdown
### Reviewer Profile: static | runtime | browser

### Runtime Validation (if runtime/browser)
```

Insert between these two lines:

```markdown

### Guidelines
- [domain]: guidelines/[domain].md
<!-- One line per relevant domain. Omit if no guidelines exist for this task's domains. -->

```

- [ ] **Step 2: Add guidelines reference to Phase B-2 Worker dispatch**

Find the B-2 dispatch list (around line 467-471):

```
Dispatch Worker subagent with:
- Full task text (from plan, not file reference)
- Sprint Contract
- Design brief (if Architect was consulted)
- Codebase context (relevant files, patterns)
- Model selection based on effort score
```

Replace with:

```
Dispatch Worker subagent with:
- Full task text (from plan, not file reference)
- Sprint Contract
- Domain Guidelines content (read from files listed in Sprint Contract's Guidelines section)
- Design brief (if Architect was consulted)
- Codebase context (relevant files, patterns)
- Model selection based on effort score
```

- [ ] **Step 3: Add guidelines reference to Reviewer dispatch in B-4**

Find the runtime review dispatch description (around line 514-518):

```
**runtime (Reviewer agent):**
1. Dispatch Reviewer subagent with diff + Sprint Contract
2. Reviewer runs validation commands from Sprint Contract
```

Replace with:

```
**runtime (Reviewer agent):**
1. Dispatch Reviewer subagent with diff + Sprint Contract + Domain Guidelines (if any)
2. Reviewer runs validation commands from Sprint Contract
```

Find the browser review dispatch description (around line 520-524):

```
**browser (Reviewer agent + browser):**
1. Dispatch Reviewer subagent with diff + Sprint Contract
2. Reviewer runs tests AND browser validation items
```

Replace with:

```
**browser (Reviewer agent + browser):**
1. Dispatch Reviewer subagent with diff + Sprint Contract + Domain Guidelines (if any)
2. Reviewer runs tests AND browser validation items
```

- [ ] **Step 4: Commit**

```bash
git add skills/team-driven-development/SKILL.md
git commit -m "feat: integrate Domain Guidelines into Sprint Contracts and dispatch"
```

---

### Task 7: Verify all changes are consistent

**Files:**
- Read: all modified files

- [ ] **Step 1: Verify term consistency across all files**

Check that these terms are used consistently:
- "Domain Guidelines" (not "domain guidelines", "Guidelines", or "guideline")
- `guidelines/{domain}.md` (not `guidelines/{domain-name}.md` or other variants)
- "Phase 0: Guideline Check" (not "Phase 0: Guidelines Check" or other variants)

Run:
```bash
grep -rn "guidelines" skills/team-driven-development/ templates/
```

Fix any inconsistencies found.

- [ ] **Step 2: Verify the process diagram is valid**

Read the updated Mermaid diagram in SKILL.md and trace the flow:
1. Phase 0 nodes connect to Phase A-0: Triage
2. Phase A-0 connects to either Lite Mode or Phase A
3. Phase A connects to Phase B connects to Phase C

Ensure no orphan nodes or broken edges.

- [ ] **Step 3: Verify Sprint Contract template matches SKILL.md example**

Compare the Sprint Contract template in `sprint-contract-template.md` with the inline example in SKILL.md Phase A-5. The Guidelines section must appear in the same position in both.

- [ ] **Step 4: Verify Worker and Reviewer prompts reference the same section name**

Both prompts should use `## Domain Guidelines (if applicable)` as the section header.

- [ ] **Step 5: Commit any fixes**

```bash
git add -A
git commit -m "fix: consistency fixes across Domain Guidelines integration"
```

Only create this commit if fixes were needed. If everything is consistent, skip.
