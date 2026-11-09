#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
script="$SCRIPTS/run-workspace"

repo=$(mk_repo); cd "$repo"
mkdir -p docs/plans docs/other
echo "# P" > docs/plans/feat.md
echo "# Q" > docs/other/feat.md
root=$(pwd -P)

out=$(bash "$script" docs/plans/feat.md)
assert_eq "$out" "$root/.team-dd/runs/feat" "creates workspace"
assert_eq "$(cat "$out/plan-path")" "docs/plans/feat.md" "writes plan-path marker"
assert_eq "$(cat .team-dd/.gitignore)" "*" "writes self-ignoring .gitignore"
assert_eq "$(bash "$script" docs/plans/feat.md)" "$out" "idempotent"
assert_not_contains "$(git status --porcelain)" ".team-dd" "workspace hidden from git status"

printf 'custom\n' > .team-dd/.gitignore
bash "$script" docs/plans/feat.md >/dev/null
assert_eq "$(cat .team-dd/.gitignore)" "custom" ".gitignore is create-only"

assert_eq "$(bash "$script" docs/other/feat.md)" "$root/.team-dd/runs/feat-other" "slug collision disambiguated by parent dir"
assert_exit 2 "missing plan exits 2" bash "$script" nope.md
assert_exit 2 "no args exits 2" bash "$script"
finish
