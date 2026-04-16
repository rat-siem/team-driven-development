# Worktree-Aware Execution Implementation Plan

> **For agentic workers:** Use team-driven-development to execute this plan.

**Goal:** Add a Worktree Check to Phase A-0 of SKILL.md so the Lead detects worktree context and adjusts Worker dispatch accordingly.

**Architecture:** Single file edit — insert a `### Worktree Check` section into Phase A-0 of `skills/team-driven-development/SKILL.md`, before the Quick Score section. No other files change.

**Tech Stack:** Git, Markdown

---

## File Map

| File | Change |
|------|--------|
| `skills/team-driven-development/SKILL.md` | Insert Worktree Check section into Phase A-0 |

---

### Task 1: Add Worktree Check to SKILL.md

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

- [ ] **Step 1: Locate insertion point**

Run: `grep -n "### Quick Score" skills/team-driven-development/SKILL.md`
Expected: one line number (e.g. `103:### Quick Score`)

- [ ] **Step 2: Verify the section above is Phase A-0**

Run: `grep -n "## Phase A-0" skills/team-driven-development/SKILL.md`
Expected: one line number above Quick Score

- [ ] **Step 3: Insert Worktree Check before Quick Score**

Find this text in the file:

```
### Quick Score
```

Insert the following block immediately before it (with a blank line between the new block and `### Quick Score`):

```
### Worktree Check

Run: `git rev-parse --git-dir`

If output contains `/worktrees/` → **Worktree Mode**:
- Refuse if `git diff-index --quiet HEAD --` fails → `"Commit or stash changes first."`
- Announce: `"Running in worktree context."`
- B-2: omit `isolation: "worktree"`.
- Skip B-6.

```

- [ ] **Step 4: Verify insertion**

Run: `grep -n "Worktree Check\|Worktree Mode\|worktrees" skills/team-driven-development/SKILL.md`
Expected: matches found for all three patterns

Run: `grep -n "### Quick Score" skills/team-driven-development/SKILL.md`
Expected: Quick Score line number is higher than Worktree Check line number (Worktree Check comes first)

Run: `grep -A6 "### Worktree Check" skills/team-driven-development/SKILL.md`
Expected: the 6-line block appears correctly

- [ ] **Step 5: Verify nothing else changed**

Run: `git diff --stat skills/team-driven-development/SKILL.md`
Expected: only additions, no deletions outside the inserted block

- [ ] **Step 6: Commit**

```bash
git add skills/team-driven-development/SKILL.md
git commit -m "feat: add Worktree Check to Phase A-0 of team-driven-development"
```
