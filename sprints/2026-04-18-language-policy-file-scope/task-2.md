# Sprint Contract: Task 2 - Insert Output Language section into file-writing agents

## Reviewer Profile: runtime

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -q "^## Output Language$" agents/worker.md` exits 0.
- [ ] `grep -q "Files you write stay English regardless of conversation language" agents/worker.md` exits 0.
- [ ] `grep -q "^## Output Language$" agents/sprint-master.md` exits 0.
- [ ] `grep -q "Files you write stay English regardless of conversation language" agents/sprint-master.md` exits 0.
- [ ] In `agents/worker.md`, the `## Output Language` heading appears after the role-definition paragraph and before `## Rules`.
- [ ] In `agents/sprint-master.md`, the `## Output Language` heading appears after the role-definition paragraph and before the `<HARD-GATE>` block.
- [ ] Tests pass: `for f in agents/worker.md agents/sprint-master.md; do grep -q "^## Output Language$" "$f" && grep -q "Files you write stay English regardless of conversation language" "$f" || { echo "FAIL: $f"; exit 1; }; done && echo PASS`

## Non-Goals
- Does not modify `agents/reviewer.md` or `agents/architect.md`.
- Does not change any SKILL.md files (those are Task 1).
- Does not alter the functional rules already present in either agent file beyond the insertion.

## Runtime Validation
- `for f in agents/worker.md agents/sprint-master.md; do grep -q "^## Output Language$" "$f" && grep -q "Files you write stay English regardless of conversation language" "$f" || { echo "FAIL: $f"; exit 1; }; done && echo PASS`
