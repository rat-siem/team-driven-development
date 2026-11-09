# Sprint Contract: Task 5 - Reviewer/Architect prompts and agent: file outputs, re-review, final scope

## Reviewer Profile: runtime

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] Created `prompts/re-review-prompt.md` and `prompts/final-review-prompt.md`; fully rewrote `prompts/reviewer-prompt.md`, `prompts/architect-prompt.md`, `agents/reviewer.md`; created `tests/scripts/test-reviewer-text.sh`.
- [ ] reviewer-prompt.md has `Review package:` and `task-N-review-r0.md`, and no `[Paste Sprint Contract`.
- [ ] re-review-prompt.md contains `ADDRESSED | NOT ADDRESSED` and `Out-of-Scope Observations`; agents/reviewer.md defines `## Mode: re-review` with both.
- [ ] final-review-prompt.md contains `model: opus` and `ledger.md`; agents/reviewer.md has `## Mode: final`.
- [ ] architect-prompt.md contains `task-N-design.md` and no `[FULL TEXT from plan]`.
- [ ] agents/reviewer.md contains `Write the full review to the output path` and keeps frontmatter `name: reviewer`.
- [ ] Tests pass: `bash tests/scripts/test-reviewer-text.sh`
- [ ] Tests pass: `bash tests/scripts/run.sh`

## Non-Goals
- Does not modify worker prompt/agent (Task 4) or SKILL.md (Task 6).
- Does not modify `agents/architect.md`.
- Does not add autonomous-ruling behavior; cap escalation to user stays in SKILL.md.

## Runtime Validation
- `bash tests/scripts/test-reviewer-text.sh`
- `bash tests/scripts/run.sh`
