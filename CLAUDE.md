# Team-Driven Development Plugin

## Overview

An implementation plugin that drives sub-agents through Lead/Worker/Reviewer/Architect role assignments.
Executes plans created by the `team-plan` skill (or, for historical specs, the legacy Superpowers planning skill) using a team composition.

## Architecture

- **Lead (Controller)**: Team composition, task assignment, integration, and quality decisions. Does not write code.
- **Worker**: Implementation in isolated worktrees with TDD and self-review.
- **Reviewer**: Reviews based on Sprint Contracts (static/runtime/browser).
- **Architect**: Summoned only for tasks requiring architectural decisions.

## Design Principles

- Uses the Superpowers Plan format as-is (dependency analysis is performed dynamically by the Lead)
- No Node.js/Go dependencies (shell scripts only)
- Review criteria pre-defined via Sprint Contracts
- Automated model selection through Effort Scoring
- Main branch protection via worktree isolation + cherry-pick

## Prompt Language Policy

- All files in this plugin repository must be written in English.
- Exception: User-facing translation files (e.g., `docs/README.ja.md`).
- Rationale: English text uses fewer tokens than equivalent Japanese text (roughly 2-3x difference due to tokenizer behavior), and a single language across all agent-facing instructions reduces ambiguity.
- Files produced by skills at runtime — specs in `docs/team-dd/specs/`, plans in `docs/team-dd/plans/`, Sprint Contracts in `sprints/<topic>/`, and any source code a Worker writes — are source files too. They must be English.
