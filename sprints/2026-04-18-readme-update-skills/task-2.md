# Sprint Contract: Task 2 - How It Works — add Phase A-0.5 Sprints Gate, rewrite Phase A

## Reviewer Profile: static

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] `README.md` contains a new `### Phase A-0.5: Sprints Gate (F4)` section positioned between `### Phase A-0: Triage` and `### Phase A: Pre-delegate (Full Mode)`.
- [ ] `README.md` `### Phase A-0: Triage` step 4 ends with `proceed to Phase A-0.5 (Full Mode)` (not `proceed to Full Mode (Phase A)`).
- [ ] `README.md` `### Phase A-0.5: Sprints Gate (F4)` body describes the existence check, the `yes/no` prompt, the sprint-master invocation on yes, the abort-with-guidance on no, and the note that Lite Mode skips the gate.
- [ ] `README.md` `### Phase A: Pre-delegate (Full Mode)` has exactly 4 numbered steps in this order: (1) read/extract tasks, (2) read `sprints/<topic>/common.md` and each `task-N.md`, (3) analyze dependencies dynamically, (4) determine team composition. The steps `Score effort per task`, `Select reviewer profile per task`, `Generate Sprint Contracts`, and `Contract QA — Validate each contract` are absent from Phase A.
- [ ] `docs/README.ja.md` contains a new `### Phase A-0.5: スプリントゲート (F4)` section in the analogous position.
- [ ] `docs/README.ja.md` `### Phase A-0: トリアージ` step 4 ends with `Phase A-0.5（Full Mode）へ`.
- [ ] `docs/README.ja.md` `### Phase A: 事前分析（Full Mode）` has exactly 4 numbered steps that mirror the English Phase A (read/extract tasks, read sprints/<topic>/ files, analyze deps, team composition). The lines `Sprint Contract を生成`, `タスクごとの Effort Score を算出`, `タスクごとの reviewer profile を選択`, and `**Contract QA** — 各 Contract を検証` are absent from Phase A.
- [ ] Phase 0, Phase B, and Phase C in both files are byte-identical to their pre-edit content.
- [ ] Exactly one commit is added; `git diff --stat HEAD~1 HEAD` shows only `README.md` and `docs/README.ja.md`.
- [ ] Tests pass: `bash -c 'set -e; grep -q "^### Phase A-0.5: Sprints Gate (F4)$" README.md; grep -qF "proceed to Phase A-0.5 (Full Mode)" README.md; ! grep -qF "5. Generate Sprint Contracts" README.md; ! grep -qF "**Contract QA** — Validate each contract" README.md; ! grep -qF "Select reviewer profile per task" README.md; ! grep -qF "Score effort per task" README.md; grep -q "^### Phase A-0.5: スプリントゲート (F4)$" docs/README.ja.md; grep -qF "Phase A-0.5（Full Mode）へ" docs/README.ja.md; ! grep -qF "5. Sprint Contract を生成" docs/README.ja.md; ! grep -qF "**Contract QA** — 各 Contract を検証" docs/README.ja.md; ! grep -qF "タスクごとの reviewer profile を選択" docs/README.ja.md; ! grep -qF "タスクごとの Effort Score を算出" docs/README.ja.md; test "$(git log -1 --name-only --pretty=format: HEAD | grep -v "^$" | sort)" = "$(printf "README.md\ndocs/README.ja.md" | sort)"'`

## Non-Goals
- Do NOT modify the `Key Features` / `主な機能` section (Task 1's scope).
- Do NOT modify the `Usage` / `使い方` section (Task 3's scope).
- Do NOT modify `Phase 0`, `Phase B`, or `Phase C` in either file. Only `Phase A-0` (step-4 retarget), the new `Phase A-0.5`, and `Phase A` body are in scope.
- Do NOT modify skill files, `CLAUDE.md`, `.claude-plugin/marketplace.json`, or anything in `skills/`, `agents/`, `templates/`, or `scripts/`.
- Do NOT rewrite the `Sprint Contract QA` bullet in the Key Features section — that bullet lives in Task 1's scope (unchanged per spec).
