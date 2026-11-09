# Sprint Contract: Task 7 - README (EN + JA)

## Reviewer Profile: runtime

## Effort Score: 0 → Model: haiku

## Success Criteria
- [ ] README.md: `Review Ledger` bullet replaced by three bullets (Run Ledger & resume, File-based handoff, Final whole-branch review); Phase B step 4 reads `Fix loop (max 5 rounds)...`; Phase C gains `Final whole-branch review (opus)` step before the old step 2 with later steps renumbered; License section adds the `obra/superpowers` attribution line; `The Review Ledger records` becomes `The Run Ledger records`.
- [ ] docs/README.ja.md: equivalent edits in Japanese (`最大5回`, `ブランチ全体の最終レビュー`, `.team-dd/runs/`, `obra/superpowers`, `Run Ledger が全指摘を`).
- [ ] Neither README contains `max 3 rounds`; docs/README.ja.md contains no `最大3回`.
- [ ] `tests/scripts/test-readme-text.sh` created per plan.
- [ ] Tests pass: `bash tests/scripts/test-readme-text.sh`
- [ ] Tests pass: `bash tests/scripts/run.sh`

## Non-Goals
- Does not modify SKILL.md, prompts, agents, or scripts.
- Does not rewrite README sections outside the listed bullets/steps/License.

## Runtime Validation
- `bash tests/scripts/test-readme-text.sh`
- `bash tests/scripts/run.sh`
