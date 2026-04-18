# Sprint Contract: Task 2 - Update external quick-plan references

## Reviewer Profile: runtime

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] All seven external files are updated — every one contains at least one `quick-brainstorm` occurrence and none contains any `quick-plan` / `Quick Plan` / `quick_plan` token: `skills/team-plan/SKILL.md`, `skills/team-driven-development/SKILL.md`, `skills/solo-review/SKILL.md`, `skills/deep-brainstorm/SKILL.md`, `README.md`, `docs/README.ja.md`, `guidelines/writing.md`.
- [ ] Whole-repo verification — `grep -rnE 'quick-plan|quick_plan|Quick Plan' . --exclude-dir=.git --exclude-dir=docs` produces no output.
- [ ] Explicit check on the translation file (excluded from the repo-wide scan) — `grep -nE 'quick-plan|quick_plan|Quick Plan' docs/README.ja.md` produces no output.
- [ ] Discoverability check — `grep -L quick-brainstorm skills/quick-brainstorm/SKILL.md skills/team-plan/SKILL.md skills/team-driven-development/SKILL.md skills/solo-review/SKILL.md skills/deep-brainstorm/SKILL.md README.md docs/README.ja.md guidelines/writing.md` produces an empty list.
- [ ] Historical-artifact protection — `git diff --name-only HEAD~1..HEAD -- 'docs/superpowers/**' 'docs/team-dd/specs/2026-04-17-*.md' 'docs/team-dd/plans/2026-04-17-*.md' 'docs/team-dd/specs/2026-04-18-sprint-master-design.md' 'docs/team-dd/plans/2026-04-18-sprint-master.md'` produces no output (Task 2's commit must not touch any of these paths).
- [ ] Case-style preservation — in `README.md` and `docs/README.ja.md`, every former `Quick Plan` is now `Quick Brainstorm` (not `Quick brainstorm`), and every former `quick-plan` is now `quick-brainstorm` (confirmed by grepping for `Quick brainstorm` and getting no results).
- [ ] Exactly one commit is added by this task, covering all seven modified files and nothing else.
- [ ] Tests pass: `bash -c '! grep -rnE "quick-plan|quick_plan|Quick Plan" . --exclude-dir=.git --exclude-dir=docs && ! grep -nE "quick-plan|quick_plan|Quick Plan" docs/README.ja.md && [ -z "$(grep -L quick-brainstorm skills/quick-brainstorm/SKILL.md skills/team-plan/SKILL.md skills/team-driven-development/SKILL.md skills/solo-review/SKILL.md skills/deep-brainstorm/SKILL.md README.md docs/README.ja.md guidelines/writing.md)" ]'`

## Non-Goals
- Do NOT edit `docs/superpowers/**` or any `docs/team-dd/*` file predating this plan — historical artifacts must remain byte-identical.
- Do NOT edit `CLAUDE.md`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, or anything under `agents/`, `templates/`, or `scripts/` — all verified free of `quick-plan` tokens.
- Do NOT re-edit `skills/quick-brainstorm/SKILL.md` (owned by Task 1); re-touching it fragments the Task 1 rename diff.
- Do NOT rewrite surrounding sentences, adjust Japanese phrasing in `docs/README.ja.md` beyond the literal substitution, or add/remove bullet points. The only change is the token replacement.
- Do NOT add new cross-references between the renamed skill and others that did not exist before.

## Runtime Validation
- `bash -c '! grep -rnE "quick-plan|quick_plan|Quick Plan" . --exclude-dir=.git --exclude-dir=docs && ! grep -nE "quick-plan|quick_plan|Quick Plan" docs/README.ja.md && [ -z "$(grep -L quick-brainstorm skills/quick-brainstorm/SKILL.md skills/team-plan/SKILL.md skills/team-driven-development/SKILL.md skills/solo-review/SKILL.md skills/deep-brainstorm/SKILL.md README.md docs/README.ja.md guidelines/writing.md)" ]'`
- `grep -nE 'Quick brainstorm' README.md docs/README.ja.md` must produce no output (case-style preservation).
