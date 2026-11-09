# Sprint Contract: Superpowers SDD Import

## Spec
docs/team-dd/specs/2026-11-08-superpowers-sdd-import-design.md

## Plan
docs/team-dd/plans/2026-11-08-superpowers-sdd-import.md

## Base branch
develop

## Shared Criteria
- `bash tests/scripts/run.sh` exits 0 after the task's changes (every task).
- All delivered files are English, except the Japanese text in `docs/README.ja.md`.
- File contents match the plan's code/text blocks verbatim; no `TODO`/`[TBD]` placeholders.
- Bash scripts: `#!/usr/bin/env bash`, `set -euo pipefail`, header line `# Adapted from obra/superpowers (MIT License, Copyright (c) 2025 Jesse Vincent).`, always invoked via `bash`, errors on stderr, exit codes as specified in the spec's Helper Scripts table.
- Skill/prompt/agent text follows Token Economy (guidelines/writing.md); no pasted plan or contract text in dispatch prompts.
- Only files listed in the task's plan `**Files:**` block are changed; Lite Mode section of SKILL.md, `agents/sprint-master.md`, `agents/architect.md`, team-plan and brainstorm skills stay unmodified.
- Commit message matches the plan's Step 5 message for the task.

## Domain Guidelines
- writing: guidelines/writing.md
