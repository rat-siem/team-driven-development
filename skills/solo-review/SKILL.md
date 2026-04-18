---
name: solo-review
description: Standalone code review using the team-driven-development Reviewer agent. Auto-detects review target and criteria, dispatches Reviewer, reports structured verdict. Use when you want a code review without running the full team workflow.
---

# Solo Review

Run the team-driven-development Reviewer as a standalone agent — no plan, no team orchestration required. Get a structured, evidence-based code review on any set of changes.

**Announce at start:** "I'm using solo-review to review the current changes."

## Language Policy

Render user-facing prose (announce, gates, status, errors) in the user's language; explicit user request overrides. Keep literal: commands, paths, `<placeholders>`, backtick-wrapped identifiers (e.g., `PASS`, `DONE`), severity/disposition labels, status markers (📌🔍❓⚠), Markdown structure (headings, table column headers). Default to match recent user input; English if no signal.

## Arguments

Parse the skill arguments to determine review target and options:

- No arguments → auto-detect target
- Commit range (e.g., `HEAD~3..HEAD`) → use as diff range
- Path (e.g., `src/api/`) → filter changes to that path
- `--profile static|runtime|browser` → override reviewer profile
- `--contract <path>` → use specified Sprint Contract

Examples:
- `/solo-review` — auto-detect everything
- `/solo-review HEAD~3..HEAD` — review last 3 commits
- `/solo-review src/api/ --profile runtime` — review API changes with runtime validation
- `/solo-review --contract docs/team-dd/sprint-contract.md` — use specific Sprint Contract

## Review Target Detection

Determine what to review, in priority order:

1. **If arguments specify a range or path** → use that directly
2. **If staged changes exist** (`git diff --cached` is non-empty) → review staged changes
3. **If unstaged changes exist** (`git diff` is non-empty) → review all uncommitted changes
4. **If current branch differs from main** (`git diff main...HEAD` is non-empty) → review branch changes
5. **If nothing detected** → ask the user what to review

Run the detection:

```bash
# Check staged
git diff --cached --stat

# Check unstaged
git diff --stat

# Check branch diff
git diff main...HEAD --stat
```

Report what was detected:

> "Reviewing [staged changes | uncommitted changes | branch changes vs main] ([N] files changed)"

## Review Criteria (3-Level Fallback)

Determine review criteria based on available context:

### Level 1: Sprint Contract (highest priority)

If `--contract` argument provided or a Sprint Contract is found in context:
- Use the contract directly
- Follow exact Sprint Contract checklist format
- This is identical to team-driven-development Phase B-4 review
- Preferred contract location: `sprints/<topic>/task-N.md` (produced by `sprint-master`). `--contract` accepts this path directly.

### Level 2: Plan-Derived Criteria

If no contract but a plan file exists in `docs/team-dd/plans/` or `docs/superpowers/plans/`:

1. Read plan files and find tasks whose "Files:" sections overlap with the changed files
2. Extract success criteria and test commands from matching tasks
3. Build a review checklist from the extracted criteria
4. Report: "Found plan [filename] — using criteria from Tasks [N, M]"

### Level 3: Generic Code Review (fallback)

If no contract and no plan:

Use these general criteria:

| # | Criterion | Severity | Check |
|---|-----------|----------|-------|
| 1 | No security vulnerabilities | critical | Injection, XSS, auth bypass, secrets in code |
| 2 | No data loss risk | critical | Destructive operations without safeguards |
| 3 | Existing features not broken | major | Changed behavior of public interfaces |
| 4 | New logic has tests | major | New functions/methods without corresponding tests |
| 5 | Error handling for external calls | major | Unhandled error paths in API/DB/file calls |
| 6 | Type safety | minor | Missing annotations, unsafe casts (does not block) |
| 7 | Code style and naming | minor | Consistency with codebase (does not block) |

Report: "No Sprint Contract or plan found — using generic code review criteria"

## Reviewer Profile Selection

If `--profile` argument provided, use it. Otherwise, auto-detect:

Examine the list of changed files:

| Changed files contain | Profile |
|----------------------|---------|
| UI/CSS/component files (`.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.html`) | `browser` |
| Test files or project has test scripts in package.json/pyproject.toml | `runtime` |
| Only logic/config files | `static` |

Check in order: browser → runtime → static (first match wins).

Report: "Reviewer profile: [static | runtime | browser] ([reason])"

## Dispatch Reviewer

### Static Profile (review directly)

For `static` profile, review the diff directly in this session:

1. Read the full diff
2. Evaluate each criterion from the review checklist
3. Record findings with severity classification
4. Produce the verdict report

### Runtime / Browser Profile (dispatch subagent)

For `runtime` or `browser` profiles, dispatch a Reviewer subagent:

```
Agent tool:
  subagent_type: "team-driven-development:reviewer"
  model: sonnet
  mode: "bypassPermissions"
  description: "solo-review: [brief description of changes]"
  prompt: |
    ## Review Profile: [runtime | browser]

    Evaluate every criterion in ## Review Criteria. SKIPPED is not allowed.

    ## Review Criteria

    [Paste the criteria — Sprint Contract, plan-derived checklist, or generic criteria table]

    ## Changes to Review

    [Paste git diff or summary of changes]

    ## Files Changed

    [List all changed files]

    Use `## Review: solo-review` as the report header.
```

## Output

Present the Reviewer's report to the user as-is. Do not enter a fix loop — solo-review reports findings and returns. The user decides what to do with the results.

If the verdict is REQUEST_CHANGES, end with:

> "Review found issues that need attention. Fix the findings above and run `/solo-review` again to re-check."

If the verdict is APPROVE, end with:

> "Review passed — no blocking issues found."

## Integration

**Works with:**
- **team-driven-development** — Shares the same Reviewer agent definition and report format
- **quick-brainstorm** — Plan files generated by quick-brainstorm can be used as Level 2 criteria source

**Does not depend on:**
- superpowers (fully self-contained within this plugin)
