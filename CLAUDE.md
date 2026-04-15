# Team-Driven Development Plugin

## Overview

An implementation plugin that drives sub-agents through Lead/Worker/Reviewer/Architect role assignments.
Executes plans created by the Superpowers `writing-plans` skill using a team composition.

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
