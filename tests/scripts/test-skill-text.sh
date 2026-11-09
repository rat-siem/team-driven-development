#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
s=$(cat "$REPO_ROOT/skills/team-driven-development/SKILL.md")

assert_not_contains "$s" "Managed in Lead's context" "ledger no longer context-only"
assert_not_contains "$s" "max 3 rounds" "old 3-round cap removed"
assert_contains "$s" "### Run Ledger" "Run Ledger section"
assert_contains "$s" "ledger.md" "ledger file"
assert_contains "$s" "### A-0: Run Workspace and Resume" "resume section"
assert_contains "$s" "scripts/run-workspace" "uses run-workspace"
assert_contains "$s" "scripts/task-brief" "uses task-brief"
assert_contains "$s" "scripts/review-package" "uses review-package"
assert_contains "$s" "### B-5: Fix Loop (max 5 rounds)" "5-round fix loop"
assert_contains "$s" "SendMessage" "rounds 1-3 resume Worker"
assert_contains "$s" "### C-1.5: Final Whole-Branch Review" "final review phase"
assert_contains "$s" "final-review-prompt.md" "final review template referenced"
assert_contains "$s" "re-review-prompt.md" "re-review template referenced"
assert_contains "$s" "### Final Review Residuals" "residuals in completion report"
assert_contains "$s" "Run workspace: .team-dd/runs/" "C-4 workspace cleanup"
finish
