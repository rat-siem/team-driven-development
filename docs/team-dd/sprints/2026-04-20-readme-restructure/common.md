# Sprint Contract: README Restructure

## Spec
docs/team-dd/specs/2026-04-20-readme-restructure-design.md

## Plan
docs/team-dd/plans/2026-04-20-readme-restructure.md

## Shared Criteria
- Both README.md and docs/README.ja.md must reach the same 17-section top-level order defined in the spec's Target Structure.
- The `## Key Features` and `## What It Does` headings must be absent from README.md; `## 主な機能` and `## 概要` must be absent from docs/README.ja.md.
- Skill identifier headings (`### quick-brainstorm`, `### deep-brainstorm`, `### superpowers:brainstorming`, `### team-plan`, `### team-driven-development`, `### sprint-master`, `### solo-review`) must appear under Skills in both files.
- `sprint-master` and `solo-review` must appear only under Supporting skills in the Skills section and under a Supporting section in Usage — never in the core-pipeline table or the entry-point flow diagram.
- No mention of `subagent-driven-development` or "extension of Superpowers" framing may appear in either file.
- The Usage preface line in README.md must read verbatim: "Every skill ships with the plugin. Skills interoperate with Superpowers' `brainstorming` and `writing-plans` because the spec/plan formats are shared."
- Bilingual parity: the H2 section count in docs/README.ja.md must equal the H2 section count in README.md.
- Slash commands, file paths, and flag names in docs/README.ja.md must remain verbatim English; only prose and annotations are translated.

## Domain Guidelines
- docs: guidelines/docs.md
