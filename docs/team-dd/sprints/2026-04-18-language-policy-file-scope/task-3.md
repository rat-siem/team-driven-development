# Sprint Contract: Task 3 - Append skill-generated-files bullet to CLAUDE.md

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -q "Files produced by skills at runtime" CLAUDE.md` exits 0.
- [ ] The bullet appears under `## Prompt Language Policy` as the last bullet in that section.
- [ ] The bullet text is verbatim: `Files produced by skills at runtime — specs in \`docs/team-dd/specs/\`, plans in \`docs/team-dd/plans/\`, Sprint Contracts in \`sprints/<topic>/\`, and any source code a Worker writes — are source files too. They must be English.`

## Non-Goals
- Does not modify any section of `CLAUDE.md` other than `## Prompt Language Policy`.
- Does not add any new sections or headings to `CLAUDE.md`.
