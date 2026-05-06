# Sprint Contract: Worktree Base Branch Selection

## Spec
docs/team-dd/specs/2026-05-07-worktree-base-branch-design.md

## Plan
docs/team-dd/plans/2026-05-07-worktree-base-branch.md

## Base branch
develop

## Shared Criteria
- Each file edit must pass `grep`-based verification as defined in the task's verification step before committing.
- No string from the "before" old_string may remain in the file after editing (obsolete strings must be gone).
- Commit message follows `feat(<scope>): <description>` pattern with the scope matching the file's directory/skill name.
- Branch names containing shell metacharacters must be rejected with `Invalid branch name: '<value>'`; this invariant is visible in prose added to each skill.
- All inserted text is English; no placeholder text (e.g., `TODO`, `[TBD]`) left in delivered files.

## Domain Guidelines
- writing: guidelines/writing.md
