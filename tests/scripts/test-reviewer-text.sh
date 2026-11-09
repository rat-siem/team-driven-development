#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
p="$REPO_ROOT/skills/team-driven-development/prompts"
rp=$(cat "$p/reviewer-prompt.md")
ap=$(cat "$p/architect-prompt.md")
ra=$(cat "$REPO_ROOT/agents/reviewer.md")

assert_file "$p/re-review-prompt.md" "re-review prompt exists"
assert_file "$p/final-review-prompt.md" "final review prompt exists"
rr=$(cat "$p/re-review-prompt.md")
fr=$(cat "$p/final-review-prompt.md")
assert_not_contains "$rp" "[Paste Sprint Contract" "reviewer prompt has no pasted contract"
assert_contains "$rp" "Review package:" "reviewer prompt passes review package path"
assert_contains "$rp" "task-N-review-r0.md" "reviewer output path"
assert_contains "$rr" "ADDRESSED | NOT ADDRESSED" "re-review verdict vocabulary"
assert_contains "$rr" "Out-of-Scope Observations" "re-review out-of-scope section"
assert_contains "$fr" "model: opus" "final review on opus"
assert_contains "$fr" "ledger.md" "final review reads ledger"
assert_not_contains "$ap" "[FULL TEXT from plan]" "architect prompt has no pasted plan"
assert_contains "$ap" "task-N-design.md" "architect output saved as design brief"
assert_contains "$ra" "## Mode: re-review" "agent re-review mode"
assert_contains "$ra" "## Mode: final" "agent final mode"
assert_contains "$ra" "Write the full review to the output path" "agent writes to output file"
finish
