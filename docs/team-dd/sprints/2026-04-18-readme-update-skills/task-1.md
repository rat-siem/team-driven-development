# Sprint Contract: Task 1 - Key Features — add Deep Brainstorm / Team Plan / Sprint Master, update Quick Brainstorm

## Reviewer Profile: static

## Effort Score: 1 → Model: haiku

## Success Criteria
- [ ] `README.md` Key Features section lists, in order and adjacent: `Quick Brainstorm`, `Deep Brainstorm`, `Team Plan`, `Sprint Master`, then `Solo Review`. Each appears as its own top-level bullet starting with `- **<Name>** — `.
- [ ] `README.md` Quick Brainstorm bullet contains the exact handoff chain `quick-brainstorm → team-plan → sprint-master → team-driven-development`.
- [ ] `README.md` Deep Brainstorm bullet mentions all three phase names (`Distill`, `Challenge`, `Harden`) and `Decision Log`.
- [ ] `README.md` Team Plan bullet mentions both `docs/team-dd/specs/` and `docs/team-dd/plans/`, and states that it invokes `sprint-master`.
- [ ] `README.md` Sprint Master bullet mentions both `common.md` and `task-N.md` and references the `F4 Sprints Gate`.
- [ ] `docs/README.ja.md` 主な機能 section mirrors the English ordering (同じ5項目が同じ順序で並ぶ: Quick Brainstorm, Deep Brainstorm, Team Plan, Sprint Master, Solo Review).
- [ ] `docs/README.ja.md` Quick Brainstorm bullet contains the exact handoff chain `quick-brainstorm → team-plan → sprint-master → team-driven-development`.
- [ ] `docs/README.ja.md` Deep Brainstorm, Team Plan, Sprint Master bullets exist with the same structural information as their English counterparts (three phase names in Deep Brainstorm; specs/plans paths and sprint-master invocation in Team Plan; common.md / task-N.md / F4 Sprints Gate in Sprint Master).
- [ ] Existing `Solo Review` bullet (both files) is byte-identical to its pre-edit content.
- [ ] Existing `Adaptive process selection` through `Domain Guidelines` bullets (both files) are byte-identical to their pre-edit content.
- [ ] Exactly one commit is added; `git diff --stat HEAD~1 HEAD` shows only `README.md` and `docs/README.ja.md`.
- [ ] Tests pass: `bash -c 'set -e; grep -q "^- \*\*Deep Brainstorm\*\* — " README.md; grep -q "^- \*\*Team Plan\*\* — " README.md; grep -q "^- \*\*Sprint Master\*\* — " README.md; grep -qF "quick-brainstorm → team-plan → sprint-master → team-driven-development" README.md; grep -q "^- \*\*Deep Brainstorm\*\* — " docs/README.ja.md; grep -q "^- \*\*Team Plan\*\* — " docs/README.ja.md; grep -q "^- \*\*Sprint Master\*\* — " docs/README.ja.md; grep -qF "quick-brainstorm → team-plan → sprint-master → team-driven-development" docs/README.ja.md; test "$(git log -1 --name-only --pretty=format: HEAD | grep -v "^$" | sort)" = "$(printf "README.md\ndocs/README.ja.md" | sort)"'`

## Non-Goals
- Do NOT modify the `How It Works` / `動作フロー` section (Task 2's scope).
- Do NOT modify the `Usage` / `使い方` section (Task 3's scope).
- Do NOT modify skill files, `CLAUDE.md`, `.claude-plugin/marketplace.json`, `agents/**`, `templates/**`, or `scripts/**`.
- Do NOT reword the existing `Solo Review` bullet or any bullet below `Solo Review` in Key Features.
- Do NOT change the Key Features section heading (`## Key Features` / `## 主な機能`).
