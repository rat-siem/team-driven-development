# Review Ledger & Review Quality Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Review Ledger tracking, structured review output, Sprint Contract QA, and cherry-pick conflict handling to the team-driven-development plugin.

**Architecture:** All changes are prompt/documentation modifications — no runtime code. Six files are modified to introduce the Review Ledger concept, enforce structured output from Workers and Reviewers, add a Contract QA gate, define cherry-pick conflict resolution, and enhance the Completion Report.

**Tech Stack:** Markdown (prompt engineering)

---

## Task 1: Worker Self-Review Structuring

Modify Worker agent definition and dispatch prompt to produce Ledger-compatible structured findings.

**Files:**
- Modify: `agents/worker.md:26-33` (Report Format section)
- Modify: `skills/team-driven-development/prompts/worker-prompt.md:72-102` (Self-Review Checklist and Report Format)

- [ ] **Step 1: Update `agents/worker.md` Report Format**

Replace the current Report Format section (lines 26-33):

```markdown
## Report Format

When done, report:
- **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
- What you implemented
- Test results (commands run and output)
- Files changed (list all)
- Self-review findings
- Concerns (if any)
```

With:

```markdown
## Report Format

When done, report:
- **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
- **What you implemented:** [summary]
- **Test results:** [commands run and output]
- **Files changed:** [list all]

### Self-Review Findings

| # | Severity | File:Line | Finding | Action |
|---|----------|-----------|---------|--------|
| W-1 | minor | src/foo.ts:42 | Unused import | fixed |
| W-2 | major | src/bar.ts:15 | Edge case not handled | fixed |

If no findings: "Self-review complete. No issues found."

- **Concerns** (if DONE_WITH_CONCERNS): [description]
```

- [ ] **Step 2: Update `prompts/worker-prompt.md` Report Format**

Replace the current Report Format section at the end of the prompt template (lines 93-102):

```markdown
    ## Report Format

    - **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
    - What you implemented
    - Test results (commands + output)
    - Files changed (full list)
    - Self-review findings
    - Concerns (if any)
```

With:

```markdown
    ## Report Format

    - **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
    - **What you implemented:** [summary]
    - **Test results:** [commands + output]
    - **Files changed:** [full list]

    ### Self-Review Findings

    Report findings from your self-review in this table format. Use W-prefixed IDs.

    | # | Severity | File:Line | Finding | Action |
    |---|----------|-----------|---------|--------|
    | W-1 | [critical/major/minor/recommendation] | [file:line] | [what you found] | fixed |

    If no findings: "Self-review complete. No issues found."

    - **Concerns** (if DONE_WITH_CONCERNS): [description]
```

- [ ] **Step 3: Verify self-review checklist is preserved in `prompts/worker-prompt.md`**

Confirm that the Self-Review Checklist section (lines 71-91) with Completeness / Quality / Discipline / Testing headings remains unchanged. The structured findings table is an output format for that checklist, not a replacement.

- [ ] **Step 4: Commit**

```bash
git add agents/worker.md skills/team-driven-development/prompts/worker-prompt.md
git commit -m "feat: add structured self-review findings to Worker output format"
```

---

## Task 2: Reviewer Prompt Enhancement

Add mandatory evidence table, finding IDs, and no-SKIPPED rule to Reviewer agent and dispatch prompt.

**Files:**
- Modify: `agents/reviewer.md:44-70` (Report Format section)
- Modify: `skills/team-driven-development/prompts/reviewer-prompt.md:76-109` (Report Format section)

- [ ] **Step 1: Update `agents/reviewer.md` Report Format**

Replace the current Report Format section (lines 44-70):

```markdown
## Report Format

\```markdown
## Review: Task N - [Name]

### Verdict: APPROVE | REQUEST_CHANGES

### Findings

#### Critical
- [finding with file:line reference]

#### Major
- [finding with file:line reference]

#### Minor
- [finding — noted, does not block]

#### Recommendations
- [suggestion for future improvement]

### Sprint Contract Checklist
- [x] Criterion 1 — met
- [ ] Criterion 2 — NOT met: [explanation]

### Validation Results
- `test command`: PASS/FAIL [output summary]
\```
```

With:

```markdown
## Report Format

\```markdown
## Review: Task N - [Name]

### Verdict: APPROVE | REQUEST_CHANGES

### Sprint Contract Checklist

Every criterion MUST be evaluated. SKIPPED is not allowed.

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | [criterion text] | MET | [what you observed] |
| 2 | [criterion text] | NOT_MET | [what's missing or wrong] |

Coverage: N/N criteria evaluated

### Findings

Use R-prefixed unique IDs for all findings.

#### Critical
- **R-1** file:line — [description]

#### Major
- **R-2** file:line — [description]

#### Minor
- **R-3** file:line — [description — noted, does not block]

#### Recommendations
- **R-4** [suggestion]

### Validation Results
- `test command`: PASS/FAIL [output summary]
\```
```

- [ ] **Step 2: Update `prompts/reviewer-prompt.md` Report Format**

Replace the current Report Format section (lines 76-109):

```markdown
    ## Report Format

    \```markdown
    ## Review: Task N - [Name]

    ### Verdict: APPROVE | REQUEST_CHANGES

    ### Sprint Contract Checklist
    - [x] Criterion 1 — met
    - [ ] Criterion 2 — NOT met: [explanation]

    ### Non-Goals Check
    - [x] No over-building detected
    OR
    - [ ] Over-building: [what was added beyond spec]

    ### Validation Results
    - `command`: PASS/FAIL
      [output summary]

    ### Findings

    #### Critical
    - [file:line — description]

    #### Major
    - [file:line — description]

    #### Minor
    - [description — noted, does not block]

    #### Recommendations
    - [suggestion]
    \```
```

With:

```markdown
    ## Report Format

    \```markdown
    ## Review: Task N - [Name]

    ### Verdict: APPROVE | REQUEST_CHANGES

    ### Sprint Contract Checklist

    Every criterion MUST be evaluated. SKIPPED is not allowed.

    | # | Criterion | Status | Evidence |
    |---|-----------|--------|----------|
    | 1 | [criterion from contract] | MET | [what you observed — cite file:line or command output] |
    | 2 | [criterion from contract] | NOT_MET | [what's missing or wrong] |

    Coverage: N/N criteria evaluated

    ### Non-Goals Check
    - [x] No over-building detected
    OR
    - [ ] Over-building: [what was added beyond spec]

    ### Validation Results
    - `command`: PASS/FAIL
      [output summary]

    ### Findings

    Use R-prefixed unique IDs for all findings.

    #### Critical
    - **R-1** file:line — [description]

    #### Major
    - **R-2** file:line — [description]

    #### Minor
    - **R-3** file:line — [description — noted, does not block]

    #### Recommendations
    - **R-4** [suggestion]
    \```
```

- [ ] **Step 3: Update `prompts/reviewer-prompt.md` Sprint Contract Validation instructions**

In the "Your Job" section (lines 33-39), replace:

```markdown
    ### 1. Sprint Contract Validation

    Check EVERY success criterion in the Sprint Contract:
    - Mark each as MET or NOT MET
    - For NOT MET items, explain specifically what's missing
```

With:

```markdown
    ### 1. Sprint Contract Validation

    Evaluate EVERY success criterion in the Sprint Contract. SKIPPED is not allowed.
    - For each criterion, record Status (MET or NOT_MET) and Evidence (what you observed)
    - Evidence must cite specific file:line references or command output
    - Report using the evidence table format in the Report Format section
```

- [ ] **Step 4: Commit**

```bash
git add agents/reviewer.md skills/team-driven-development/prompts/reviewer-prompt.md
git commit -m "feat: add evidence table and finding IDs to Reviewer output format"
```

---

## Task 3: SKILL.md — Review Ledger Concept and Static Review Template

Add the Review Ledger concept section and structured static review template to the main skill definition.

**Files:**
- Modify: `skills/team-driven-development/SKILL.md:386-405` (Phase B-4 Review section)

- [ ] **Step 1: Add Review Ledger section after "The Team" section**

Insert a new section after "### When to Summon the Architect" (after line 61) and before "## The Process" (line 63):

```markdown
### Review Ledger

The Lead maintains a **Review Ledger** for each task — a structured record of all review findings, their severity, and how they were resolved. The Ledger is managed in the Lead's context (not written to filesystem) and feeds into the Completion Report.

#### Ledger Format

```markdown
## Review Ledger: Task N - [Task Name]

### Round 1

#### Worker Self-Review
| # | Severity | File:Line | Finding | Source |
|---|----------|-----------|---------|--------|
| W-1 | minor | src/foo.ts:42 | Unused import | self-review |

#### Reviewer Findings
| # | Severity | File:Line | Finding | Source |
|---|----------|-----------|---------|--------|
| R-1 | major | src/bar.ts:15 | Missing null check | reviewer |

#### Disposition
| # | Source | Severity | Disposition | Detail |
|---|--------|----------|-------------|--------|
| W-1 | self-review | minor | fixed | Removed in same commit |
| R-1 | reviewer | major | fixed | Added null check, commit abc123 |

### Final Status: APPROVE (Round N)
```

#### Disposition Rules

- **Three dispositions only:** `fixed`, `deferred` (reason required), `wont-fix` (reason required)
- **critical/major findings MUST be `fixed`.** Only minor/recommendation may be `deferred` or `wont-fix`.
- Lead verifies all criteria show MET before proceeding to cherry-pick.
```

- [ ] **Step 2: Update Phase B-4 static review instructions**

Replace the current static review instructions in Phase B-4 (lines 388-392):

```markdown
**static (Lead reviews directly):**
1. Read the Worker's diff
2. Check each Sprint Contract criterion
3. Verify non-goals were respected
4. Verdict: APPROVE or REQUEST_CHANGES with specific issues
```

With:

```markdown
**static (Lead reviews directly):**
1. Read the Worker's diff
2. Check each Sprint Contract criterion — record in Ledger using the evidence table format:

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | [criterion] | MET/NOT_MET | [what you observed] |

Coverage: N/N criteria evaluated

3. Verify non-goals were respected
4. Record findings with L-prefixed IDs (L-1, L-2, ...) in the Ledger
5. Verdict: APPROVE or REQUEST_CHANGES with specific issues
```

- [ ] **Step 3: Add Ledger integration to Phase B-4 runtime/browser instructions**

After the existing runtime and browser instructions (lines 393-405), append:

```markdown
**All profiles — Ledger integration:**

After review (static, runtime, or browser), the Lead:
1. Transfers Worker self-review findings (W-prefixed) into the Ledger
2. Transfers Reviewer findings (R-prefixed) or Lead findings (L-prefixed) into the Ledger
3. Records disposition for each finding
4. Verifies critical/major findings are all `fixed` before proceeding
```

- [ ] **Step 4: Commit**

```bash
git add skills/team-driven-development/SKILL.md
git commit -m "feat: add Review Ledger concept and static review template to SKILL.md"
```

---

## Task 4: SKILL.md — Sprint Contract QA (Phase A-5.5)

Insert the Contract QA gate between Sprint Contract generation and team composition.

**Files:**
- Modify: `skills/team-driven-development/SKILL.md:293-332` (Phase A section)
- Modify: `skills/team-driven-development/sprint-contract-template.md` (add QA reference)

- [ ] **Step 1: Insert Phase A-5.5 into SKILL.md**

After the existing "### A-5: Sprint Contract Generation" section (ends around line 320) and before "### A-6: Team Composition" (line 322), insert:

```markdown
### A-5.5: Contract QA

Before dispatching any Worker, the Lead validates each Sprint Contract against this checklist:

```
Contract QA Checklist:
1. [ ] All Success Criteria are specific and verifiable
       NG: "Code works correctly"
       OK: "GET /api/users returns 200 with JSON array"
2. [ ] Test commands include file paths or filters
3. [ ] At least one Non-Goal is defined
4. [ ] Reviewer Profile matches task characteristics
5. [ ] Dependencies on incomplete tasks are stated as preconditions
```

**If any item fails:** Lead fixes the Contract directly and re-checks once. If still failing after one fix attempt, the task definition is ambiguous — escalate to human.
```

- [ ] **Step 2: Add QA reference to `sprint-contract-template.md`**

At the end of the file (after line 91), append:

```markdown

## Contract QA

After generating each Sprint Contract, the Lead runs a QA check before dispatching the Worker. See SKILL.md Phase A-5.5 for the full checklist. Key validations:

- Success Criteria must be specific and verifiable (not vague)
- Test commands must include file paths or filters
- At least one Non-Goal must be defined
- Reviewer Profile must match task characteristics
- Dependencies must be stated as preconditions if the dependent task is not yet complete
```

- [ ] **Step 3: Update Phase A process graph in SKILL.md**

In the `cluster_phase_a` subgraph (lines 91-105), add the A-5.5 node. Replace:

```
        "A5: Generate Sprint Contracts" -> "A6: Determine team composition";
```

With:

```
        "A5.5: Contract QA" [shape=box];

        "A5: Generate Sprint Contracts" -> "A5.5: Contract QA";
        "A5.5: Contract QA" -> "A6: Determine team composition";
```

- [ ] **Step 4: Commit**

```bash
git add skills/team-driven-development/SKILL.md skills/team-driven-development/sprint-contract-template.md
git commit -m "feat: add Sprint Contract QA gate (Phase A-5.5)"
```

---

## Task 5: SKILL.md — Cherry-pick Conflict Handling

Define the conflict resolution flow in Phase B-6.

**Files:**
- Modify: `skills/team-driven-development/SKILL.md:427-439` (Phase B-6 section)

- [ ] **Step 1: Replace Phase B-6 in SKILL.md**

Replace the current B-6 section (lines 427-439):

```markdown
### B-6: Cherry-pick to Main

On APPROVE:
```bash
git cherry-pick --no-commit <worktree-commit-hash>
git commit -m "<task description>"
```

Report progress:
```
Task N/Total complete — "[task name]"
```
```

With:

```markdown
### B-6: Cherry-pick to Main

On APPROVE:
```bash
git cherry-pick --no-commit <worktree-commit-hash>
git commit -m "<task description>"
```

**If cherry-pick conflicts:**

1. **Lead resolves directly.** Read conflict markers. Resolve using both the task's intent and existing main state. Adjacent-line conflicts from parallel tasks are expected and typically straightforward.
2. **If resolution is non-trivial** (semantic conflict, not just adjacency): re-dispatch Reviewer on the resolved result. This additional review round does not count toward the 3-round limit.
3. **If Lead cannot resolve:** Escalate to human with conflict details, both sides' intent, and recommended resolution.
4. **Record in Ledger:** Note "Cherry-pick conflict resolved by Lead" or "Re-reviewed after conflict resolution" in the task's Ledger.

Report progress:
```
Task N/Total complete — "[task name]"
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/team-driven-development/SKILL.md
git commit -m "feat: add cherry-pick conflict handling to Phase B-6"
```

---

## Task 6: SKILL.md — Enhanced Completion Report

Update the Phase C Completion Report to pull Review Ledger data.

**Files:**
- Modify: `skills/team-driven-development/SKILL.md:449-478` (Phase C section)

- [ ] **Step 1: Replace Phase C-2 Completion Report in SKILL.md**

Replace the current Completion Report template (lines 457-477):

````markdown
### C-2: Completion Report

```markdown
## Completion Report

### Tasks Completed: N/N

| Task | Status | Files Changed | Reviewer Profile | Rounds |
|------|--------|--------------|-----------------|--------|
| 1    | Done   | 3            | static          | 1      |
| 2    | Done   | 7            | runtime         | 2      |
| ...  | ...    | ...          | ...             | ...    |

### Summary
- Total files changed: N
- Total commits: N
- Architect consulted: Tasks [2, 5]
- Review rounds: avg N per task

### Commit Log
- abc1234: Task 1 - [description]
- def5678: Task 2 - [description]
```
````

With:

````markdown
### C-2: Completion Report

```markdown
## Completion Report

### Tasks Completed: N/N

| Task | Status | Files | Profile | Rounds | Findings |
|------|--------|-------|---------|--------|----------|
| 1    | Done   | 3     | static  | 1      | 0 critical, 0 major, 1 minor |
| 2    | Done   | 7     | runtime | 2      | 0 critical, 1 major, 2 minor |

### Review Detail

Include this section for each task that has findings. Omit for tasks with zero findings.

#### Task N - [Name]
| # | Source | Severity | Finding | Disposition | Detail |
|---|--------|----------|---------|-------------|--------|
| W-1 | self-review | minor | Unused import | fixed | — |
| R-1 | reviewer | major | Missing null check | fixed | Round 2, commit def567 |
| R-2 | reviewer | minor | Variable naming | deferred | Style preference, no functional impact |

### Summary
- Total files changed: N
- Total commits: N
- Architect consulted: Tasks [2, 5]
- Review rounds: avg N per task
- Findings: N critical, N major, N minor, N recommendations
- Deferred items: N (see Review Detail for reasons)

### Commit Log
- abc1234: Task 1 - [description]
- def5678: Task 2 - [description]
```
````

- [ ] **Step 2: Update Lite Mode Completion Report**

Replace the current Lite Mode Completion Report (lines 227-238):

````markdown
### Lite Mode Completion Report

```markdown
## Completion Report (Lite Mode)

### Tasks Completed: N/N

### Commit Log
- abc1234: Task 1 - [description]
- def5678: Task 2 - [description]

### Review
- Reviewer: [APPROVE | REQUEST_CHANGES → fixed in round N]
```
````

With:

````markdown
### Lite Mode Completion Report

```markdown
## Completion Report (Lite Mode)

### Tasks Completed: N/N

### Commit Log
- abc1234: Task 1 - [description]
- def5678: Task 2 - [description]

### Review
- Verdict: [APPROVE | REQUEST_CHANGES → fixed in round N]
- Findings: N critical, N major, N minor, N recommendations

### Review Detail (if findings exist)

| # | Severity | Finding | Disposition | Detail |
|---|----------|---------|-------------|--------|
| R-1 | major | Missing validation | fixed | Round 2 |
| R-2 | minor | Variable naming | deferred | Style preference |
```
````

- [ ] **Step 3: Commit**

```bash
git add skills/team-driven-development/SKILL.md
git commit -m "feat: add Review Ledger detail to Completion Report"
```
