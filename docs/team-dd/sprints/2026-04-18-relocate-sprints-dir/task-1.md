# Sprint Contract: Task 1 - Relocate existing sprint directories

## Reviewer Profile: runtime

## Effort Score: 3 → Model: opus

## Success Criteria
- [ ] `test ! -e sprints && echo OK` prints `OK` — the root-level `sprints/` directory no longer exists.
- [ ] `ls -1 docs/team-dd/sprints/ | wc -l | tr -d ' '` prints `6` — all six feature directories are present at the new location.
- [ ] `git log --follow --oneline docs/team-dd/sprints/2026-04-18-language-policy-file-scope/task-3.md | wc -l | tr -d ' '` prints a number >= 1 — git history is preserved on a sample file via rename tracking.
- [ ] `git status --short | grep -E '^R' | wc -l | tr -d ' '` is non-zero immediately after the `git mv` operations and before the commit — git staged the moves as renames, not deletes+adds.
- [ ] Tests pass: `test ! -e /Volumes/Workspace/personal/team-driven-development/sprints && ls /Volumes/Workspace/personal/team-driven-development/docs/team-dd/sprints/ | wc -l`

## Non-Goals
- This task does not update any path string references in documentation, skill, or agent files — that is Task 2's responsibility.
- This task does not modify any file contents; it only moves directory trees.
- This task does not touch `docs/team-dd/plans/` or `docs/team-dd/specs/` files.

## Runtime Validation
- `test ! -e sprints && echo "root sprints gone" || echo "FAIL: root sprints still exists"`
- `ls -1 docs/team-dd/sprints/`
- `git log --follow --oneline docs/team-dd/sprints/2026-04-18-language-policy-file-scope/task-3.md | head -5`
