# Prompt Reduction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce token consumption across all dispatch prompts and skills by eliminating redundancy, using typed subagents, and replacing prohibition lists with positive directives.

**Architecture:** Switch dispatch prompts from `general-purpose` to typed subagents so role definitions load automatically from `agents/*.md`. Remove duplicated role definitions from dispatch prompts, keeping only task-specific context. Delete Red Flags sections (replaced by mandatory positive directives) and non-operational Integration sections.

**Tech Stack:** Git, Markdown

---

## File Map

| File | Change |
|------|--------|
| `skills/team-driven-development/prompts/worker-prompt.md` | Rewrite — remove role definition, switch subagent_type |
| `skills/team-driven-development/prompts/reviewer-prompt.md` | Rewrite — remove role definition, switch subagent_type |
| `skills/team-driven-development/prompts/architect-prompt.md` | Rewrite — remove role definition, switch subagent_type |
| `skills/team-driven-development/SKILL.md` | Delete Red Flags + Integration; add "Review is mandatory" in two locations |
| `skills/quick-plan/SKILL.md` | Delete Red Flags; delete "What does NOT need a question" block |
| `skills/solo-review/SKILL.md` | Slim dispatch prompt body; delete Red Flags |
| `agents/*.md` | Not modified |
| `templates/sprint-contract-template.md` | Not modified |

Tasks 2–7 all require Task 1 (develop branch). Tasks 2–7 are independent of each other.

---

### Task 1: Create develop branch

**Files:**
- No file changes — git operation only

- [ ] **Step 1: Verify clean working tree**

Run: `git status`
Expected: `nothing to commit, working tree clean`

- [ ] **Step 2: Create and switch to develop branch**

Run:
```bash
git checkout -b develop
```
Expected: `Switched to a new branch 'develop'`

- [ ] **Step 3: Verify**

Run: `git branch --show-current`
Expected: `develop`

---

### Task 2: Rewrite worker-prompt.md

Switch subagent_type to typed agent. Remove role definition, Your Job, Self-Review Checklist, Escalation, and Report Format — all already defined in `agents/worker.md`.

**Files:**
- Modify: `skills/team-driven-development/prompts/worker-prompt.md`

- [ ] **Step 1: Verify current state contains role definition**

Run: `grep -c "You are a Worker" skills/team-driven-development/prompts/worker-prompt.md`
Expected: `1`

- [ ] **Step 2: Write new file content**

Replace the entire file with:

```
# Worker Dispatch Prompt

` `` `
Agent tool:
  subagent_type: "team-driven-development:worker"
  model: [haiku|sonnet|opus per effort score]
  isolation: "worktree"
  mode: "bypassPermissions"
  description: "Implement Task N: [task name]"
  prompt: |
    ## Task
    [FULL TEXT from plan — paste it, never reference a file]

    ## Sprint Contract
    [Paste Sprint Contract]

    ## Design Brief (if Architect consulted)
    [Paste brief, or omit section]

    ## Domain Guidelines (if applicable)
    [Paste content of guidelines/{domain}.md files from Contract's Guidelines section.
     Omit if none apply.]

    ## Codebase Context
    [Pre-read code and patterns Worker needs. Lead extracts this.]

    If anything is unclear — requirements, approach, dependencies — ask now.
` `` `
```

Note: ` `` ` above represents literal triple-backtick fences in the file.

- [ ] **Step 3: Verify role definition is removed**

Run: `grep "You are a Worker" skills/team-driven-development/prompts/worker-prompt.md`
Expected: no output (exit code 1)

- [ ] **Step 4: Verify subagent_type**

Run: `grep "subagent_type" skills/team-driven-development/prompts/worker-prompt.md`
Expected: `  subagent_type: "team-driven-development:worker"`

- [ ] **Step 5: Commit**

```bash
git add skills/team-driven-development/prompts/worker-prompt.md
git commit -m "refactor: slim worker dispatch — typed subagent, remove role duplication"
```

---

### Task 3: Rewrite reviewer-prompt.md

Switch subagent_type to typed agent. Remove role definition, Review Steps, Severity table, and Rules — all in `agents/reviewer.md`.

**Files:**
- Modify: `skills/team-driven-development/prompts/reviewer-prompt.md`

- [ ] **Step 1: Verify current state**

Run: `grep -c "You are a Reviewer" skills/team-driven-development/prompts/reviewer-prompt.md`
Expected: `1`

- [ ] **Step 2: Write new file content**

Replace the entire file with:

```
# Reviewer Dispatch Prompt

For `runtime` and `browser` profiles only — `static` reviews are done by Lead.

` `` `
Agent tool:
  subagent_type: "team-driven-development:reviewer"
  model: sonnet
  mode: "bypassPermissions"
  description: "Review Task N: [task name]"
  prompt: |
    ## Review Profile: [runtime | browser]

    ## Sprint Contract
    [Paste Sprint Contract — includes incorporated Domain Guidelines criteria]

    ## Changes
    [Git diff or summary with key changes. For large diffs, summarize and highlight concerns.]

    ## Files Changed
    [List all modified/created files]
` `` `
```

Note: ` `` ` above represents literal triple-backtick fences in the file.

- [ ] **Step 3: Verify**

Run: `grep "You are a Reviewer" skills/team-driven-development/prompts/reviewer-prompt.md`
Expected: no output

Run: `grep "subagent_type" skills/team-driven-development/prompts/reviewer-prompt.md`
Expected: `  subagent_type: "team-driven-development:reviewer"`

- [ ] **Step 4: Commit**

```bash
git add skills/team-driven-development/prompts/reviewer-prompt.md
git commit -m "refactor: slim reviewer dispatch — typed subagent, remove role duplication"
```

---

### Task 4: Rewrite architect-prompt.md

Switch subagent_type to typed agent. Remove role definition, Your Job steps, Design Brief Format, and Rules — all in `agents/architect.md`.

**Files:**
- Modify: `skills/team-driven-development/prompts/architect-prompt.md`

- [ ] **Step 1: Verify current state**

Run: `grep -c "You are an Architect" skills/team-driven-development/prompts/architect-prompt.md`
Expected: `1`

- [ ] **Step 2: Write new file content**

Replace the entire file with:

```
# Architect Dispatch Prompt

` `` `
Agent tool:
  subagent_type: "team-driven-development:architect"
  model: opus
  description: "Design review for Task N: [task name]"
  prompt: |
    ## Task
    [FULL TEXT from plan]

    ## Codebase Context
    [Relevant code, patterns, architecture. Include file contents for key modules.]

    ## Related Tasks
    [Tasks that depend on or interact with this task's output.]

    ## Why You're Needed
    - [Specific reason]
` `` `
```

Note: ` `` ` above represents literal triple-backtick fences in the file.

- [ ] **Step 3: Verify**

Run: `grep "You are an Architect" skills/team-driven-development/prompts/architect-prompt.md`
Expected: no output

Run: `grep "subagent_type" skills/team-driven-development/prompts/architect-prompt.md`
Expected: `  subagent_type: "team-driven-development:architect"`

- [ ] **Step 4: Commit**

```bash
git add skills/team-driven-development/prompts/architect-prompt.md
git commit -m "refactor: slim architect dispatch — typed subagent, remove role duplication"
```

---

### Task 5: Update SKILL.md

Delete Red Flags and Integration sections. Add "Review is mandatory" at Phase B header and "Mandatory — never skip" at Lite Mode step 3.

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

- [ ] **Step 1: Verify sections to delete exist**

Run: `grep -n "## Red Flags\|## Integration" skills/team-driven-development/SKILL.md`
Expected: two line number matches

- [ ] **Step 2: Delete the Red Flags section**

Find and remove this exact block:

```
## Red Flags

**Never (Full Mode):** Implement on main without consent. Skip review. Let Lead write code. Dispatch with unresolved dependencies. Parallelize shared-file tasks. Ignore BLOCKED/NEEDS_CONTEXT. Accept REQUEST_CHANGES without fixes. Skip Sprint Contracts. Let Architect implement. Cherry-pick before review.

**Never (Lite Mode):** Skip Reviewer. Exceed 2 rounds without escalating. Use Lite if user declined proposal.

**Worker questions:** Answer completely first. **Review issues:** Fix and re-review. **Architect/Worker disagree:** Lead mediates per plan.
```

- [ ] **Step 3: Delete the Integration section**

Find and remove this exact block:

```
## Integration

- **quick-plan** — generates spec + plan for this skill
- **superpowers:writing-plans** — creates plans this skill executes
- **superpowers:using-git-worktrees** — Worker worktree isolation
- **superpowers:test-driven-development** — Workers follow TDD
- **superpowers:finishing-a-development-branch** — after completion
- Alternative: **superpowers:subagent-driven-development** — simpler single-role execution
```

- [ ] **Step 4: Add mandatory review directive to Phase B header**

Find:
```
## Phase B: Delegate

Execute in dependency order.
```

Replace with:
```
## Phase B: Delegate

**Review is mandatory.** Every task — Full and Lite — dispatches a Reviewer before cherry-pick. No exceptions.

Execute in dependency order.
```

- [ ] **Step 5: Add "Mandatory — never skip" to Lite Mode step 3**

Find:
```
3. Dispatch Reviewer on full diff (base SHA → HEAD). Template: `./prompts/reviewer-prompt.md`.
```

Replace with:
```
3. Dispatch Reviewer on full diff (base SHA → HEAD). Template: `./prompts/reviewer-prompt.md`. **Mandatory — never skip.**
```

- [ ] **Step 6: Verify all changes**

Run: `grep "Red Flags" skills/team-driven-development/SKILL.md`
Expected: no output

Run: `grep "## Integration" skills/team-driven-development/SKILL.md`
Expected: no output

Run: `grep -c "Review is mandatory\|never skip" skills/team-driven-development/SKILL.md`
Expected: `2`

- [ ] **Step 7: Commit**

```bash
git add skills/team-driven-development/SKILL.md
git commit -m "refactor: remove Red Flags + Integration; add mandatory review directive"
```

---

### Task 6: Update quick-plan/SKILL.md

Delete Red Flags section (covered by HARD-GATE and checklist). Delete "What does NOT need a question" block (inverse of the positive rule — self-evident).

**Files:**
- Modify: `skills/quick-plan/SKILL.md`

- [ ] **Step 1: Verify sections to delete exist**

Run: `grep -n "## Red Flags\|What does NOT" skills/quick-plan/SKILL.md`
Expected: two line number matches

- [ ] **Step 2: Delete the Red Flags section**

Find and remove this exact block (at end of file):

```
## Red Flags

**Never:**
- Write implementation code during quick-plan (spec + plan only)
- Skip user confirmation gates (both spec and plan require approval)
- Ask questions that could be answered by reading the codebase
- Generate abbreviated or "lite" documents — output quality is always full
- Invoke superpowers:brainstorming or superpowers:writing-plans
- Proceed to plan generation before spec is approved
```

- [ ] **Step 3: Delete "What does NOT need a question" block**

Find and remove this exact block from the Clarification Logic section:

```
**What does NOT need a question:**
- Technology choice when the codebase already uses a specific stack
- File location when existing conventions make it obvious
- Error handling approach when the codebase has an established pattern
- Testing strategy when the project has existing test patterns
```

- [ ] **Step 4: Verify**

Run: `grep "Red Flags\|What does NOT" skills/quick-plan/SKILL.md`
Expected: no output

- [ ] **Step 5: Commit**

```bash
git add skills/quick-plan/SKILL.md
git commit -m "refactor: remove Red Flags and redundant prohibition block from quick-plan"
```

---

### Task 7: Update solo-review/SKILL.md

Solo-review already correctly uses `team-driven-development:reviewer` subagent type. Remove the role definition body from the dispatch prompt (Your Job, Severity Rules, Code Quality Scan, Report Format — all in `agents/reviewer.md`). Delete Red Flags section.

**Files:**
- Modify: `skills/solo-review/SKILL.md`

- [ ] **Step 1: Verify role definition exists in dispatch prompt**

Run: `grep -n "You are a Reviewer agent" skills/solo-review/SKILL.md`
Expected: one line number match

- [ ] **Step 2: Slim the dispatch prompt body**

Inside the Agent tool dispatch block (the `prompt: |` section), find everything from:
```
    You are a Reviewer agent performing a standalone code review.
```
through the end of the `## Report Format` block (the closing triple-backtick of the report format example), and replace with:

```
    ## Review Profile: [runtime | browser]

    ## Review Criteria

    [Paste the criteria — Sprint Contract, plan-derived checklist, or generic criteria table]

    ## Changes to Review

    [Paste git diff or summary of changes]

    ## Files Changed

    [List all changed files]
```

The sections removed are: opening role statement, `### 1. Criteria Validation`, `### 2. Runtime Validation`, `### 3. Browser Validation`, `### 4. Code Quality Scan`, `## Severity Rules`, `## Report Format`.

- [ ] **Step 3: Delete the Red Flags section**

Find and remove this exact block:

```
## Red Flags

**Never:**
- Enter a fix loop (solo-review is report-only)
- Skip criteria evaluation (every criterion must be MET or NOT_MET)
- Block on minor/recommendation findings
- Modify any code (review only, no changes)
- Dispatch a Worker or Architect (Reviewer only)
```

- [ ] **Step 4: Verify**

Run: `grep "You are a Reviewer agent\|Red Flags\|Your Job\|Severity Rules" skills/solo-review/SKILL.md`
Expected: no output

Run: `grep "Review Profile\|Review Criteria\|Changes to Review" skills/solo-review/SKILL.md`
Expected: matches found (context headers remain)

- [ ] **Step 5: Commit**

```bash
git add skills/solo-review/SKILL.md
git commit -m "refactor: slim solo-review dispatch prompt; remove Red Flags section"
```
