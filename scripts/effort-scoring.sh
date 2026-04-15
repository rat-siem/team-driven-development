#!/usr/bin/env bash
# effort-scoring.sh — Calculate effort score for a task
#
# Usage: effort-scoring.sh <task-id> <plan-file>
#
# Analyzes a task section from a plan file and outputs an effort score (0-5)
# with factor breakdown. The Lead uses this to select the Worker model.

set -euo pipefail

TASK_ID="${1:?Usage: effort-scoring.sh <task-id> <plan-file>}"
PLAN_FILE="${2:?Usage: effort-scoring.sh <task-id> <plan-file>}"

if [ ! -f "$PLAN_FILE" ]; then
  echo "Error: Plan file not found: $PLAN_FILE" >&2
  exit 1
fi

# Extract task section
TASK_CONTENT=$(sed -n "/^### Task ${TASK_ID}:/,/^### Task [0-9]/p" "$PLAN_FILE" | sed '$d')

if [ -z "$TASK_CONTENT" ]; then
  echo "Error: Task ${TASK_ID} not found in ${PLAN_FILE}" >&2
  exit 1
fi

SCORE=0
FACTORS=""

# Factor 1: File count (4+ files = +1)
FILE_COUNT=$(echo "$TASK_CONTENT" | grep -cE '^\s*- (Create|Modify|Test):' || echo 0)
if [ "$FILE_COUNT" -ge 4 ]; then
  SCORE=$((SCORE + 1))
  FACTORS="${FACTORS}  +1 file_count (${FILE_COUNT} files)\n"
fi

# Factor 2: Directory risk (core/, shared/, security/, auth/, config/)
if echo "$TASK_CONTENT" | grep -qiE '(core/|shared/|security/|auth/|config/)'; then
  SCORE=$((SCORE + 1))
  FACTORS="${FACTORS}  +1 directory_risk (touches sensitive directory)\n"
fi

# Factor 3: Keywords (architecture, migration, security, design, refactor)
if echo "$TASK_CONTENT" | grep -qiE '(architecture|migration|security|design|refactor)'; then
  SCORE=$((SCORE + 1))
  FACTORS="${FACTORS}  +1 keywords (complex task indicators)\n"
fi

# Factor 4: Cross-cutting (check if task files appear in other tasks)
TASK_FILES=$(echo "$TASK_CONTENT" | grep -oE '[a-zA-Z0-9/_.-]+\.(ts|js|py|go|rs|rb|java|tsx|jsx|css|scss)' | sort -u)
if [ -n "$TASK_FILES" ]; then
  # Get all tasks except current
  OTHER_TASKS=$(sed -n "/^### Task [0-9]/,/^### Task [0-9]/p" "$PLAN_FILE" | grep -v "^### Task ${TASK_ID}:")
  for f in $TASK_FILES; do
    if echo "$OTHER_TASKS" | grep -q "$f"; then
      SCORE=$((SCORE + 1))
      FACTORS="${FACTORS}  +1 cross_cutting (shared file: ${f})\n"
      break
    fi
  done
fi

# Factor 5: New subsystem (creates new directory)
if echo "$TASK_CONTENT" | grep -qE '^\s*- Create:.*/' ; then
  # Check if creating files in a directory that doesn't appear in existing codebase
  NEW_DIRS=$(echo "$TASK_CONTENT" | grep -oE '^\s*- Create: `[^`]+`' | grep -oE '[a-zA-Z0-9/_-]+/' | sort -u)
  if [ -n "$NEW_DIRS" ]; then
    for d in $NEW_DIRS; do
      if [ ! -d "$d" ]; then
        SCORE=$((SCORE + 1))
        FACTORS="${FACTORS}  +1 new_subsystem (new directory: ${d})\n"
        break
      fi
    done
  fi
fi

# Model selection
if [ "$SCORE" -le 1 ]; then
  MODEL="haiku"
  COMPLEXITY="mechanical"
elif [ "$SCORE" -eq 2 ]; then
  MODEL="sonnet"
  COMPLEXITY="integration"
else
  MODEL="opus"
  COMPLEXITY="architecture/design"
fi

echo "Effort Score: ${SCORE}/5"
echo "Complexity: ${COMPLEXITY}"
echo "Recommended Model: ${MODEL}"
echo ""
echo "Factors:"
if [ -n "$FACTORS" ]; then
  printf "%b" "$FACTORS"
else
  echo "  (no complexity factors detected)"
fi
