# Sprint Contract: Task 2 - Usage — add `team-plan` to Quick Brainstorm flow and rewrite description

## Reviewer Profile: static

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] `README.md` Usage subsection code block reads `/quick-brainstorm <task description> → team-plan → team-driven-development` and the old chain `/quick-brainstorm <task description> → team-driven-development` is absent: `grep -q "/quick-brainstorm <task description> → team-plan → team-driven-development" README.md && ! grep -q "/quick-brainstorm <task description> → team-driven-development" README.md`
- [ ] `docs/README.ja.md` Usage subsection code block reads `/quick-brainstorm <タスクの説明> → team-plan → team-driven-development` and the old chain is absent: `grep -q "/quick-brainstorm <タスクの説明> → team-plan → team-driven-development" docs/README.ja.md && ! grep -q "/quick-brainstorm <タスクの説明> → team-driven-development" docs/README.ja.md`
- [ ] `README.md` description no longer says "generates a spec and plan with minimal dialogue" (corrected to spec only): `! grep -q "generates a spec and plan with minimal dialogue" README.md`
- [ ] `docs/README.ja.md` description no longer says "spec と plan を生成します" in the Usage subsection: `! grep -q "spec と plan を生成します" docs/README.ja.md`
- [ ] `README.md` description states that `team-plan` invokes `sprint-master` internally to generate Sprint Contract files: `grep -q "sprint-master" README.md`
- [ ] The auto-suggest behavior note (team-driven-development without a plan suggests quick-brainstorm) is preserved in both files.
- [ ] No other Usage subsections are modified (Deep Brainstorm, Solo Review, Standalone entries unchanged).

## Non-Goals
- Modifying the Key Features section (handled by Task 1).
- Editing the Deep Brainstorm Usage subsection — it already follows the correct convention.
- Removing `sprint-master` from How It Works phase descriptions or the F4 Sprints Gate block (those are manual-invocation patterns and remain valid).
- Changing any prose outside the "With Quick Brainstorm (self-contained)" and "Quick Brainstorm と併用（自己完結）" subsections.
- Touching CLAUDE.md, skill files, or marketplace.json.
