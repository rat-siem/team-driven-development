# Implementation Summary in Completion Report

> **For agentic workers:** Use team-driven-development to execute this plan.

**Goal:** Add `### Implementation Summary`, `### Test Results`, and `### Deferred Items` sections to both Full Mode and Lite Mode Completion Reports, and extend Worker output format to supply the data.

**Architecture:** Two prompt-document files are edited — `SKILL.md` for Lead behavior and `worker-prompt.md` for Worker output format. No code compilation or test runner involved; verification is done by reading the updated files and confirming consistency.

**Tech Stack:** Markdown prompt files only.

---

## File Structure

| File | Role |
|------|------|
| `skills/team-driven-development/SKILL.md` | Lead orchestration instructions — contains Completion Report templates |
| `skills/team-driven-development/prompts/worker-prompt.md` | Worker dispatch template — defines expected Worker output |

---

### Task 1: Extend Worker Output Format

**Files:**
- Modify: `skills/team-driven-development/prompts/worker-prompt.md`

- [ ] **Step 1: Write a failing test (manual)**
  Open `worker-prompt.md` and verify it currently does NOT contain `## Implementation Summary`. Confirm before editing.

- [ ] **Step 2: Add Implementation Summary to Worker output**

  In `worker-prompt.md`, after the existing prompt block, append an "Expected Output" section that instructs the Worker to include an implementation summary. Replace the closing ` ``` ` of the prompt block so the output format is part of the prompt content.

  Locate the closing line of the prompt block:
  ```
      If anything is unclear — requirements, approach, dependencies — ask now.
  ```

  Add the following directly after that line (still inside the prompt block, before the closing triple-backtick):

  ```
      ## Expected Output

      ### Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
      ### Implementation Summary
      [What was built — 2–4 sentences]
      ### Files Changed
      - Created/Modified: path — purpose/change
      ### Test Results
      - Command: `<cmd>`; N passed, N failed, N skipped
      ### Commits
      - <hash>: <message>
      (DONE_WITH_CONCERNS: add ### Concerns after Commits)
  ```

- [ ] **Step 3: Verify**
  Read the updated file and confirm:
  - `## Expected Output` section is present
  - `### Implementation Summary` heading appears
  - `### Test Results` heading appears
  - File is syntactically valid Markdown

- [ ] **Step 4: Commit**
  ```bash
  git add skills/team-driven-development/prompts/worker-prompt.md
  git commit -m "feat: add Implementation Summary to Worker output format"
  ```

---

### Task 2: Update SKILL.md — Worker Summary Collection (B-3)

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

- [ ] **Step 1: Verify current state**
  Read B-3 in `SKILL.md` (around line 238). Confirm it does NOT yet mention collecting implementation summaries.

- [ ] **Step 2: Update B-3 to capture summary**

  Locate the B-3 table:
  ```markdown
  | Status | Action |
  |--------|--------|
  | DONE | Proceed to review |
  | DONE_WITH_CONCERNS | Address correctness/scope concerns before review. Note observational concerns, proceed |
  | NEEDS_CONTEXT | Provide info, re-dispatch |
  | BLOCKED | Context problem → more context. Complexity → capable model. Too large → subtasks. Plan wrong → escalate |
  ```

  Add one line below the table:

  ```markdown
  **On DONE/DONE_WITH_CONCERNS:** Store `### Implementation Summary`, `### Files Changed`, `### Test Results` per task → C-2. Missing summary → synthesise from commits+diff. Missing test results → "not reported".
  ```

- [ ] **Step 3: Verify**
  Read the updated section and confirm the new line appears correctly after the status table.

- [ ] **Step 4: Commit**
  ```bash
  git add skills/team-driven-development/SKILL.md
  git commit -m "feat: capture Worker implementation summary in B-3"
  ```

---

### Task 3: Update SKILL.md — C-1 Collect Results

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

- [ ] **Step 1: Verify current state**
  Read C-1 in `SKILL.md` (around line 280). Current text:
  ```
  Gather commit hashes, file changes, test results.
  ```

- [ ] **Step 2: Update C-1**

  Replace:
  ```markdown
  ### C-1: Collect Results
  Gather commit hashes, file changes, test results.
  ```

  With:
  ```markdown
  ### C-1: Collect Results
  Gather commit hashes, file changes, test results, implementation summaries, deferred details (from B-3).
  ```

- [ ] **Step 3: Verify**
  Confirm the line reads correctly.

- [ ] **Step 4: Commit**
  ```bash
  git add skills/team-driven-development/SKILL.md
  git commit -m "feat: include implementation summaries in C-1 collect step"
  ```

---

### Task 4: Update SKILL.md — Full Mode Completion Report (C-2)

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

- [ ] **Step 1: Verify current state**
  Read C-2 (around line 283). Current template:
  ```markdown
  ## Completion Report
  ### Tasks Completed: N/N
  | Task | Status | Files | Profile | Rounds | Findings |
  |------|--------|-------|---------|--------|----------|
  ### Review Detail (per task with findings)
  | # | Source | Severity | Finding | Disposition | Detail |
  |---|--------|----------|---------|-------------|--------|
  ### Summary
  - Files changed / Commits / Architect consulted / Avg rounds / Findings / Deferred
  ### Commit Log
  - hash: Task N - [description]
  ```

- [ ] **Step 2: Add Implementation Summary, Test Results, and Deferred Items sections**

  Replace the C-2 template with:
  ```markdown
  ## Completion Report
  ### Tasks Completed: N/N
  | Task | Status | Files | Profile | Rounds | Findings | Tests |
  |------|--------|-------|---------|--------|----------|-------|
  ### Implementation Summary
  #### Task N: [name]
  [What was built — 2–4 sentences] **Files:** f1, f2
  ### Test Results (skip if all clean)
  | Task | Command | Passed | Failed | Skipped |
  ### Review Detail (per task with findings)
  | # | Source | Severity | Finding | Disposition | Detail |
  ### Deferred Items (skip if none)
  | # | Task | Severity | Finding | Disposition | Reason |
  ### Summary
  - Files changed / Commits / Architect consulted / Avg rounds / Findings / Deferred
  ### Commit Log
  - hash: Task N - description
  ```

- [ ] **Step 3: Verify**
  Read the updated section and confirm:
  - `### Implementation Summary` appears between task table and Test Results
  - `### Test Results` appears before Review Detail
  - `### Deferred Items` appears after Review Detail
  - Tasks table has a "Tests" column

- [ ] **Step 4: Commit**
  ```bash
  git add skills/team-driven-development/SKILL.md
  git commit -m "feat: add Implementation Summary to Full Mode Completion Report"
  ```

---

### Task 5: Update SKILL.md — Lite Mode Completion Report

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

- [ ] **Step 1: Verify current state**
  Read the Lite Mode Completion Report section (around line 147). Current template:
  ```markdown
  ## Completion Report (Lite Mode)
  ### Tasks Completed: N/N
  ### Commit Log
  - abc1234: Task 1 - [description]
  ### Review
  - Verdict: [APPROVE | REQUEST_CHANGES → fixed round N]
  - Findings: Nc, NM, Nm, Nr
  ### Review Detail (if findings)
  | # | Severity | Finding | Disposition | Detail |
  |---|----------|---------|-------------|--------|
  ```

- [ ] **Step 2: Add Implementation Summary, Test Results, and Deferred Items sections**

  Replace the Lite Mode Completion Report template with:
  ```markdown
  ## Completion Report (Lite Mode)
  ### Tasks Completed: N/N
  ### Implementation Summary
  [What was built — 2–4 sentences. Per-task if N > 2.] **Files:** f1, f2
  ### Commit Log
  - hash: Task N - description
  ### Test Results
  - `<cmd>`; N passed, 0 failed
  ### Review
  - Verdict: APPROVE | REQUEST_CHANGES → fixed round N
  - Findings: Nc, NM, Nm, Nr
  ### Review Detail (skip if none)
  | # | Severity | Finding | Disposition | Detail |
  ### Deferred Items (skip if none)
  | # | Severity | Finding | Disposition | Reason |
  ```

- [ ] **Step 3: Verify**
  Confirm:
  - `### Implementation Summary` appears after `### Tasks Completed` and before `### Commit Log`
  - `### Test Results` appears after `### Commit Log` and before `### Review`
  - `### Deferred Items` appears at the end

- [ ] **Step 4: Commit**
  ```bash
  git add skills/team-driven-development/SKILL.md
  git commit -m "feat: add Implementation Summary to Lite Mode Completion Report"
  ```
