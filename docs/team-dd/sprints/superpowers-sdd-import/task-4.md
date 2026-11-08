# Sprint Contract: Task 4 - Worker prompt and agent: file handoff, short return, no-subagents

## Reviewer Profile: runtime

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `skills/team-driven-development/prompts/worker-prompt.md` and `agents/worker.md` fully rewritten to the plan's content; `tests/scripts/test-worker-text.sh` created.
- [ ] worker-prompt.md contains `## Read First`, `task-N-brief.md`, `task-N-report.md`, `## You Do Not Dispatch Subagents`, `SendMessage` (fix rounds 1-3 template), and `## Prior Attempts` (fresh Worker template).
- [ ] worker-prompt.md contains neither `[FULL TEXT from plan` nor `[Paste Sprint Contract]`.
- [ ] agents/worker.md contains `You do not dispatch subagents`, `## Fix Round R`, and `Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED`.
- [ ] agents/worker.md frontmatter keeps `name: worker` and `model: sonnet`.
- [ ] Tests pass: `bash tests/scripts/test-worker-text.sh`
- [ ] Tests pass: `bash tests/scripts/run.sh`

## Non-Goals
- Does not modify reviewer/architect prompts or agents/reviewer.md (Task 5).
- Does not modify SKILL.md (Task 6).
- Does not change Worker TDD/self-review rules beyond those in the plan.

## Runtime Validation
- `bash tests/scripts/test-worker-text.sh`
- `bash tests/scripts/run.sh`
