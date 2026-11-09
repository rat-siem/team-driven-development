#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
wp=$(cat "$REPO_ROOT/skills/team-driven-development/prompts/worker-prompt.md")
wa=$(cat "$REPO_ROOT/agents/worker.md")

assert_not_contains "$wp" "[FULL TEXT from plan" "no pasted plan text"
assert_not_contains "$wp" "[Paste Sprint Contract]" "no pasted contract"
assert_contains "$wp" "## Read First" "path-only Read First block"
assert_contains "$wp" "task-N-brief.md" "brief path"
assert_contains "$wp" "task-N-report.md" "report path"
assert_contains "$wp" "## You Do Not Dispatch Subagents" "no-subagents block in prompt"
assert_contains "$wp" "SendMessage" "fix rounds 1-3 resume template"
assert_contains "$wp" "## Prior Attempts" "fresh Worker template"
assert_contains "$wa" "You do not dispatch subagents" "no-subagents rule in agent"
assert_contains "$wa" "## Fix Round R" "fix-round append rule"
assert_contains "$wa" "Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED" "short return contract"
finish
