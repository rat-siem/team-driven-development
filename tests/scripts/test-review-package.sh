#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
script="$SCRIPTS/review-package"

repo=$(mk_repo); cd "$repo"
echo "# P" > plan.md
base=$(git rev-parse HEAD)
echo a > a.txt; git add a.txt; gc -m "add a"
echo b > b.txt; git add b.txt; gc -m "add b"
trunk=$(git rev-parse HEAD)

out=$(bash "$script" plan.md "$base" HEAD)
pkg="$(pwd -P)/.team-dd/runs/plan/review-$(git rev-parse --short "$base")..$(git rev-parse --short HEAD).diff"
assert_contains "$out" "wrote $pkg" "prints package path"
assert_contains "$out" "2 commit(s)" "counts all commits in range"
assert_file "$pkg" "package written"
body=$(cat "$pkg")
assert_contains "$body" "add a" "includes first commit"
assert_contains "$body" "add b" "includes last commit"
assert_contains "$body" "## Files changed" "has stat section"
assert_contains "$body" "## Diff" "has diff section"

bash "$script" plan.md "$base" HEAD "$repo/custom.diff" >/dev/null
assert_file "$repo/custom.diff" "explicit OUTFILE honored"

assert_exit 3 "empty range exits 3" bash "$script" plan.md HEAD HEAD
git checkout -q -b side "$base"
echo c > c.txt; git add c.txt; gc -m "side"
assert_exit 3 "non-descendant HEAD exits 3" bash "$script" plan.md "$trunk" HEAD
assert_exit 2 "bad ref exits 2" bash "$script" plan.md deadbeefdeadbeef HEAD
assert_exit 2 "bad arg count exits 2" bash "$script" plan.md HEAD
finish
