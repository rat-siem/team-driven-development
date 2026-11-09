#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
en=$(cat "$REPO_ROOT/README.md")
ja=$(cat "$REPO_ROOT/docs/README.ja.md")

assert_contains "$en" "Fix loop (max 5 rounds" "EN 5-round loop"
assert_not_contains "$en" "max 3 rounds" "EN old cap removed"
assert_contains "$en" "Final whole-branch review" "EN final review"
assert_contains "$en" ".team-dd/runs/" "EN run workspace"
assert_contains "$en" "obra/superpowers" "EN attribution"
assert_contains "$ja" "最大5回" "JA 5-round loop"
assert_not_contains "$ja" "最大3回" "JA old cap removed"
assert_contains "$ja" "ブランチ全体の最終レビュー" "JA final review"
assert_contains "$ja" ".team-dd/runs/" "JA run workspace"
assert_contains "$ja" "obra/superpowers" "JA attribution"
finish
