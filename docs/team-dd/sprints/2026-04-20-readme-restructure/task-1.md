# Sprint Contract: Task 1 - Rewrite README.md to the new structure

## Reviewer Profile: runtime

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -qE '^## Architecture$' README.md` exits 0
- [ ] `grep -qE '^## Skills$' README.md` exits 0
- [ ] `grep -qE '^## Choosing a Skill$' README.md` exits 0
- [ ] `grep -qE '^## Workflow$' README.md` exits 0
- [ ] `grep -qE '^## Usage$' README.md` exits 0
- [ ] `grep -qE '^## Key Features$' README.md` exits non-zero (heading removed)
- [ ] `grep -qE '^## What It Does$' README.md` exits non-zero (heading removed)
- [ ] `grep -qE '^#### Core pipeline$' README.md` exits 0
- [ ] `grep -qE '^#### Supporting skills$' README.md` exits 0
- [ ] `grep -qE '^#### Cross-cutting capabilities$' README.md` exits 0
- [ ] All seven skill `###` headings present: `quick-brainstorm`, `deep-brainstorm`, `superpowers:brainstorming`, `team-plan`, `team-driven-development`, `sprint-master`, `solo-review`
- [ ] `grep -q 'Reviewer runs inside' README.md` exits 0
- [ ] `grep -q 'subagent-driven-development' README.md` exits non-zero (forbidden framing absent)
- [ ] Tests pass: `bash /tmp/readme-checks-en.sh`

## Non-Goals
- This task does not modify docs/README.ja.md (that is Task 2).
- This task does not modify any skill files under `skills/`.
- This task does not modify CLAUDE.md.
- This task does not change the content of preserved sections (Architecture role bullets, How It Works, Sprint Contract Example, Effort Scoring, Installation, Updating, Requirements, License) — only their order and section names change where specified.

## Runtime Validation
- `bash /tmp/readme-checks-en.sh`
