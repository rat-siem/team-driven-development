# Sprint Contract: Task 2 - Mirror the restructure into docs/README.ja.md

## Reviewer Profile: runtime

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -qE '^## アーキテクチャ$' docs/README.ja.md` exits 0
- [ ] `grep -qE '^## スキル$' docs/README.ja.md` exits 0
- [ ] `grep -qE '^## スキルの選び方$' docs/README.ja.md` exits 0
- [ ] `grep -qE '^## ワークフロー$' docs/README.ja.md` exits 0
- [ ] `grep -qE '^## 使い方$' docs/README.ja.md` exits 0
- [ ] `grep -qE '^## 主な機能$' docs/README.ja.md` exits non-zero (heading removed)
- [ ] `grep -qE '^## 概要$' docs/README.ja.md` exits non-zero (heading removed)
- [ ] `grep -qE '^#### コアパイプライン$' docs/README.ja.md` exits 0
- [ ] `grep -qE '^#### 補助スキル$' docs/README.ja.md` exits 0
- [ ] `grep -qE '^#### 横断的な機能$' docs/README.ja.md` exits 0
- [ ] All seven skill `###` headings present verbatim in English: `quick-brainstorm`, `deep-brainstorm`, `superpowers:brainstorming`, `team-plan`, `team-driven-development`, `sprint-master`, `solo-review`
- [ ] `grep -q 'subagent-driven-development' docs/README.ja.md` exits non-zero (forbidden framing absent)
- [ ] H2 section count in docs/README.ja.md equals H2 section count in README.md: `[ "$(grep -c '^## ' README.md)" -eq "$(grep -c '^## ' docs/README.ja.md)" ]`
- [ ] Tests pass: `bash /tmp/readme-checks-ja.sh`

## Non-Goals
- This task does not modify README.md (completed by Task 1; used only as a section-count reference).
- This task does not translate skill identifier names, slash commands, file paths, or flag names — these remain verbatim English in the Japanese file.
- This task does not modify any skill files under `skills/`.
- This task does not modify CLAUDE.md.

## Runtime Validation
- `bash /tmp/readme-checks-ja.sh`
