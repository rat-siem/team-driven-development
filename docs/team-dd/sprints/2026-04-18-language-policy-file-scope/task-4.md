# Sprint Contract: Task 4 - Tighten Source vs. runtime note in guidelines/writing.md

## Reviewer Profile: static

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] `grep -q "including \`SKILL.md\` and anything a skill generates" guidelines/writing.md` exits 0.
- [ ] The old paragraph beginning `**Source vs. runtime.** Source files (including \`SKILL.md\`)` no longer exists in `guidelines/writing.md`.
- [ ] The replacement text is verbatim: `**Source vs. runtime.** Source files — including \`SKILL.md\` and anything a skill generates (specs, plans, Sprint Contracts, source code) — are English for tokenization and ambiguity reasons. At runtime, user-facing natural-language strings emitted by a skill (announce, gates, status, errors) must render in the user's conversation language — see the \`## Language Policy\` block inside each \`SKILL.md\`.`

## Non-Goals
- Does not modify any section of `guidelines/writing.md` other than the Source vs. runtime paragraph.
- Does not change the `## Language` section structure beyond replacing the one paragraph.
