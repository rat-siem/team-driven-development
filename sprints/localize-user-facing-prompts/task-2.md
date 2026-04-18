# Sprint Contract: Task 2 - Document source-vs-runtime distinction in guidelines/writing.md

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] Before edit: `guidelines/writing.md` contains a `## Language` section with the two existing bullets (`All .md files in this repo: English.` and `Reason: English tokenizes`) and no "Source vs. runtime" note. Verified by: `grep -q '^## Language$' guidelines/writing.md && grep -qF "All \`.md\` files in this repo: English." guidelines/writing.md && ! grep -qF "Source vs. runtime" guidelines/writing.md && echo PRE_OK` outputs `PRE_OK`.
- [ ] After edit: the `## Language` section contains a new third bullet beginning with `**Source vs. runtime.**` that references `## Language Policy` and `SKILL.md`. Verified by: `grep -qF "**Source vs. runtime.**" guidelines/writing.md && grep -qF "\`## Language Policy\` block inside each \`SKILL.md\`" guidelines/writing.md && echo POST_OK` outputs `POST_OK`.
- [ ] The two pre-existing bullets are intact after the edit. Verified by: `grep -qF "All \`.md\` files in this repo: English." guidelines/writing.md && grep -qF "Reason: English tokenizes" guidelines/writing.md && echo BULLETS_OK` outputs `BULLETS_OK`.
- [ ] Tests pass: `grep -qF "Source vs. runtime" guidelines/writing.md && grep -qF "All \`.md\` files in this repo: English." guidelines/writing.md && grep -qF "Reason: English tokenizes" guidelines/writing.md && echo ALL_OK`

## Non-Goals
- This task does not modify any SKILL.md file (that is Task 1).
- This task does not change the authoring rule itself — English remains required for all source files.
- This task does not add a new language-selector mechanism or CLI flag.
- This task does not rewrite or restructure other sections of `guidelines/writing.md`.
