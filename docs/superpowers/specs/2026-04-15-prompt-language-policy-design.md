# Design: CLAUDE.md English Conversion + Prompt Language Policy

**Date**: 2026-04-15
**Status**: Approved

## Problem

CLAUDE.md contains Japanese descriptions for the plugin's architecture and design principles, while all other operational files (agent instructions, prompt templates, skill definitions) are already in English. This inconsistency should be resolved, and a language policy should be documented to guide future contributions.

## Decision

Adopt Approach A: Convert CLAUDE.md to English and add a Prompt Language Policy section.

## Scope of Changes

### 1. CLAUDE.md — Translate Japanese sections to English

The following sections contain Japanese text and will be rewritten in English:

- **Overview**: Role-based sub-agent execution plugin description
- **Architecture**: Lead, Worker, Reviewer, Architect role descriptions
- **Design Principles**: All bullet point explanations

Structure and section headings remain unchanged. This is a pure translation with no semantic changes.

### 2. CLAUDE.md — Add Prompt Language Policy section

Append a new section at the end of CLAUDE.md:

- All files in the plugin repository must be written in English
- Exception: User-facing translation files (e.g., `docs/README.ja.md`)
- Rationale: Token efficiency and cross-agent consistency

### 3. Files NOT changed

- `docs/README.ja.md` — Retained as user-facing Japanese translation
- Agent instructions, prompt templates, skill definitions — Already in English, no changes needed

## Rationale

- **Token efficiency**: Japanese text uses significantly more tokens than equivalent English text due to tokenizer behavior (roughly 2-3x for the same semantic content)
- **Agent consistency**: All agent-facing instructions in a single language reduces ambiguity
- **Contributor clarity**: Explicit policy prevents future language drift
