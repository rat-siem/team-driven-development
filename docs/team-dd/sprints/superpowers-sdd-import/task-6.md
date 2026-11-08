# Sprint Contract: Task 6 - SKILL.md: Run Ledger, resume, file handoff, 5-round fix loop, final review

## Reviewer Profile: runtime

## Effort Score: 2 → Model: sonnet

## Success Criteria
- [ ] SKILL.md: `The Team` table gains a `Final Reviewer` row (opus); `### Review Ledger` replaced by `### Run Ledger` with the plan's line grammar; Phase A through end of file replaced with the plan's text.
- [ ] SKILL.md no longer contains `Managed in Lead's context` or `max 3 rounds`.
- [ ] Contains headings `### A-0: Run Workspace and Resume`, `### B-5: Fix Loop (max 5 rounds)`, `### C-1.5: Final Whole-Branch Review`, `### Final Review Residuals`.
- [ ] References `scripts/run-workspace`, `scripts/task-brief`, `scripts/review-package`, `ledger.md`, `SendMessage`, `final-review-prompt.md`, `re-review-prompt.md`.
- [ ] C-4 block contains `Run workspace: .team-dd/runs/`.
- [ ] Lite Mode section and Phase 0 (guidelines/domain detection) text remain byte-identical to before the edit.
- [ ] Tests pass: `bash tests/scripts/test-skill-text.sh`
- [ ] Tests pass: `bash tests/scripts/run.sh`

## Non-Goals
- Does not modify prompts, agents/*.md, or READMEs (Tasks 4, 5, 7).
- Does not change Effort Scoring, Sprint Contract schema, or Lite Mode.
- Does not add autonomous adjudication at the 5-round cap; escalation stays with the user.

## Runtime Validation
- `bash tests/scripts/test-skill-text.sh`
- `bash tests/scripts/run.sh`
