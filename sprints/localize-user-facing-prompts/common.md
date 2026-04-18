# Sprint Contract: Localize User-Facing Skill Prompts

## Spec
docs/team-dd/specs/2026-04-18-localize-user-facing-prompts-design.md

## Plan
docs/team-dd/plans/2026-04-18-localize-user-facing-prompts.md

## Shared Criteria
- Placeholder variables (`<path>`, `<N>`, `<spec-path>`, etc.) are preserved verbatim inside any localized sentence — no substitution or translation of angle-bracket tokens.
- Machine-parsable identifiers (`PASS`, `APPROVE`, `DONE`, `BLOCKED`, `CHANGES_REQUESTED`, `MET`, `NOT_MET`, severity labels, disposition labels) remain literal in all languages.
- Shell commands, slash commands, file paths, and glob patterns are never translated.
- Markdown headings used as structural anchors (e.g., `## Completion Report`, `## Review Ledger`) and report table column headers remain literal.
- Status-line markers (📌 🔍 ❓ ⚠) and bracketed phase-prefix strings are never translated.
- No change to specs, plans, Sprint Contracts, or agent-to-agent protocol blocks (Worker Status, Reviewer verdicts).

## Domain Guidelines
- writing: guidelines/writing.md
