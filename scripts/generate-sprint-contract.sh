#!/usr/bin/env bash
# generate-sprint-contract.sh — Generate a Sprint Contract skeleton for a task
#
# Usage: generate-sprint-contract.sh <task-id> <plan-file>
#
# Reads the plan file, extracts the specified task, and outputs a Sprint Contract
# skeleton to stdout. The Lead should review and fill in details before use.
#
# This script does basic extraction only. The Lead (AI agent) performs the
# intelligent analysis (effort scoring, dependency resolution, reviewer profile).

set -euo pipefail

TASK_ID="${1:?Usage: generate-sprint-contract.sh <task-id> <plan-file>}"
PLAN_FILE="${2:?Usage: generate-sprint-contract.sh <task-id> <plan-file>}"

if [ ! -f "$PLAN_FILE" ]; then
  echo "Error: Plan file not found: $PLAN_FILE" >&2
  exit 1
fi

# Extract task section (from "### Task N:" to next "### Task" or end of file)
TASK_CONTENT=$(sed -n "/^### Task ${TASK_ID}:/,/^### Task [0-9]/p" "$PLAN_FILE" | sed '$d')

if [ -z "$TASK_CONTENT" ]; then
  echo "Error: Task ${TASK_ID} not found in ${PLAN_FILE}" >&2
  exit 1
fi

# Extract task name from header
TASK_NAME=$(echo "$TASK_CONTENT" | head -1 | sed "s/^### Task ${TASK_ID}: //")

# Extract files section
FILES=$(echo "$TASK_CONTENT" | sed -n '/^\*\*Files:\*\*/,/^$/p' | grep -E '^\s*-' || echo "- (none detected)")

# Count files for effort scoring hint
FILE_COUNT=$(echo "$FILES" | grep -c '^\s*-' || echo 0)

# Extract test commands (lines starting with "Run:")
TEST_COMMANDS=$(echo "$TASK_CONTENT" | grep -E '^Run:' | sed 's/^Run: //' || echo "")

# Extract step checkboxes
STEPS=$(echo "$TASK_CONTENT" | grep -E '^\s*- \[ \]' || echo "")

cat <<EOF
## Sprint Contract: Task ${TASK_ID} - ${TASK_NAME}

### Success Criteria
$(if [ -n "$STEPS" ]; then
  echo "$STEPS" | sed 's/- \[ \] \*\*[^*]*\*\*/- [ ]/' | sed 's/- \[ \] /- [ ] /'
else
  echo "- [ ] (Lead: extract criteria from task description)"
fi)
$(if [ -n "$TEST_COMMANDS" ]; then
  echo "$TEST_COMMANDS" | while read -r cmd; do
    echo "- [ ] Tests pass: \`${cmd}\`"
  done
fi)

### Non-Goals
- Do not modify files outside this task's scope
- (Lead: add task-specific non-goals)

### Reviewer Profile: (Lead: select static | runtime | browser)

$(if [ -n "$TEST_COMMANDS" ]; then
cat <<RUNTIME
### Runtime Validation
$(echo "$TEST_COMMANDS" | while read -r cmd; do
  echo "- \`${cmd}\` — expected: PASS"
done)
RUNTIME
fi)

### Effort Score: (Lead: calculate, file count hint = ${FILE_COUNT})
### Model Selection: (Lead: select based on effort score)
### Dependencies: (Lead: analyze from plan)

---
_Generated from ${PLAN_FILE}, Task ${TASK_ID}_
_Lead must review and complete all (Lead: ...) placeholders before dispatch_
EOF
