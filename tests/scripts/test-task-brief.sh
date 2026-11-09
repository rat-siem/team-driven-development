#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
script="$SCRIPTS/task-brief"

repo=$(mk_repo); cd "$repo"
cp "$REPO_ROOT/skills/sprint-master/fixtures/valid-plan.md" plan.md
ws="$(pwd -P)/.team-dd/runs/plan"

out=$(bash "$script" plan.md 2)
assert_contains "$out" "$ws/task-2-brief.md" "prints default path"
assert_contains "$(head -1 "$ws/task-2-brief.md")" "### Task 2: Add greeter CLI" "starts at Task 2 heading"
assert_not_contains "$(cat "$ws/task-2-brief.md")" "Task 1:" "excludes Task 1"

printf '%s\n' "### Task 1: one" "body1" "### Task 10: ten" "body10" > p10.md
bash "$script" p10.md 1 "$repo/o1.md" >/dev/null
assert_contains "$(cat o1.md)" "body1" "extracts Task 1 to explicit OUTFILE"
assert_not_contains "$(cat o1.md)" "body10" "Task 1 does not match Task 10"

fence=$(printf '\140\140\140')
printf '%s\n' "### Task 1: fenced" "${fence}md" "### Task 2: fake" "$fence" "after-fence" "### Task 2: real" > pf.md
bash "$script" pf.md 1 "$repo/of.md" >/dev/null
assert_contains "$(cat of.md)" "after-fence" "heading inside code fence ignored"
assert_not_contains "$(cat of.md)" "Task 2: real" "stops at next real task"

assert_exit 3 "missing task exits 3" bash "$script" plan.md 9
assert_exit 2 "missing plan exits 2" bash "$script" nope.md 1
assert_exit 2 "bad arg count exits 2" bash "$script" plan.md
finish
