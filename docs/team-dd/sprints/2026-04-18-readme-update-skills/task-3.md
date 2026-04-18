# Sprint Contract: Task 3 - Usage — self-contained preface, rename "With Superpowers" to "With Deep Brainstorm"

## Reviewer Profile: static

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] `README.md` Usage preface line no longer contains `[Superpowers]` or `github.com/obra/superpowers`; the new preface states the plugin is self-contained and that all planning, implementation, and review skills ship with it.
- [ ] `README.md` has the heading `### With Deep Brainstorm (thorough)` and does NOT have `### With Superpowers (thorough)` anywhere.
- [ ] `README.md` `### With Deep Brainstorm (thorough)` body contains the flow code block `deep-brainstorm → team-plan → team-driven-development` and text mentioning `Distill / Challenge / Harden`, extended spec, and that `team-plan` invokes `sprint-master`.
- [ ] `README.md` `### With Quick Brainstorm (self-contained)`, `### Solo Review (standalone)`, and `### Standalone` subsections are byte-identical to their pre-edit content.
- [ ] `docs/README.ja.md` Usage preface no longer contains `[Superpowers]` or `github.com/obra/superpowers`; the new preface states the plugin is 自己完結 with all skills included.
- [ ] `docs/README.ja.md` has the heading `### Deep Brainstorm と併用（じっくり）` and does NOT have `### Superpowers と併用（じっくり）` anywhere.
- [ ] `docs/README.ja.md` `### Deep Brainstorm と併用（じっくり）` body contains the same flow code block `deep-brainstorm → team-plan → team-driven-development` and text mentioning `Distill / Challenge / Harden`, 拡張 spec, and `sprint-master` による Sprint Contract ファイル生成.
- [ ] Neither `README.md` nor `docs/README.ja.md` contains `Superpowers`, `superpowers`, or `github.com/obra/superpowers` anywhere after this task.
- [ ] Exactly one commit is added; `git diff --stat HEAD~1 HEAD` shows only `README.md` and `docs/README.ja.md`.
- [ ] Tests pass: `bash -c 'set -e; ! grep -qiE "superpowers|obra/superpowers" README.md; grep -qF "plugin is self-contained" README.md; grep -q "^### With Deep Brainstorm (thorough)$" README.md; ! grep -q "^### With Superpowers" README.md; grep -qF "deep-brainstorm → team-plan → team-driven-development" README.md; ! grep -qiE "superpowers|obra/superpowers" docs/README.ja.md; grep -qF "自己完結" docs/README.ja.md; grep -q "^### Deep Brainstorm と併用（じっくり）$" docs/README.ja.md; ! grep -q "^### Superpowers と併用" docs/README.ja.md; grep -qF "deep-brainstorm → team-plan → team-driven-development" docs/README.ja.md; test "$(git log -1 --name-only --pretty=format: HEAD | grep -v "^$" | sort)" = "$(printf "README.md\ndocs/README.ja.md" | sort)"'`

## Non-Goals
- Do NOT modify the `Key Features` / `主な機能` section (Task 1's scope).
- Do NOT modify the `How It Works` / `動作フロー` section (Task 2's scope).
- Do NOT modify `### With Quick Brainstorm (self-contained)`, `### Solo Review (standalone)`, or `### Standalone` subsections — only the `Usage` preface and the renamed `With Deep Brainstorm` subsection are in scope.
- Do NOT modify skill files, `CLAUDE.md`, `.claude-plugin/marketplace.json`, or anything in `skills/`, `agents/`, `templates/`, or `scripts/`.
- Do NOT re-add Superpowers references elsewhere in the README as a replacement for the removed framing; the plugin's self-contained posture is the intended final state.
