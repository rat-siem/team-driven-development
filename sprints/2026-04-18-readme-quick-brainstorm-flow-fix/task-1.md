# Sprint Contract: Task 1 - Key Features — fix Quick Brainstorm flow chain (drop `sprint-master`)

## Reviewer Profile: static

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] `README.md` Key Features Quick Brainstorm entry contains `quick-brainstorm → team-plan → team-driven-development` and does not contain `quick-brainstorm → team-plan → sprint-master → team-driven-development`: `grep -q "quick-brainstorm → team-plan → team-driven-development" README.md && ! grep -q "quick-brainstorm → team-plan → sprint-master → team-driven-development" README.md`
- [ ] `docs/README.ja.md` Key Features Quick Brainstorm entry contains the updated chain and does not contain the old chain: `grep -q "quick-brainstorm → team-plan → team-driven-development" docs/README.ja.md && ! grep -q "quick-brainstorm → team-plan → sprint-master → team-driven-development" docs/README.ja.md`
- [ ] `sprint-master` does not appear adjacent to any arrow in `README.md`: `! grep -E "sprint-master *(→|->) " README.md && ! grep -E " (→|->) *sprint-master" README.md`
- [ ] `sprint-master` does not appear adjacent to any arrow in `docs/README.ja.md`: `! grep -E "sprint-master *(→|->) " docs/README.ja.md && ! grep -E " (→|->) *sprint-master" docs/README.ja.md`
- [ ] The prose note that `team-plan` invokes `sprint-master` internally is present in both files after the flow chain.
- [ ] No other Key Features entries are modified (Deep Brainstorm, Team Plan, Sprint Master, Solo Review entries unchanged).

## Non-Goals
- Modifying the Usage subsection (handled by Task 2).
- Changing the Deep Brainstorm Key Features entry — it already follows the correct convention.
- Removing prose references to `sprint-master` in the Sprint Master or Team Plan dedicated entries.
- Editing How It Works phase descriptions or F4 Sprints Gate text.
- Touching CLAUDE.md, skill files, or marketplace.json.
