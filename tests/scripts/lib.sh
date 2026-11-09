# Shared helpers for tests/scripts/test-*.sh. Source, do not execute.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS="$REPO_ROOT/skills/team-driven-development/scripts"
FAILS=0

pass() { printf 'ok   %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1" >&2; FAILS=$((FAILS + 1)); }
assert_eq() { if [ "$1" = "$2" ]; then pass "$3"; else fail "$3 (got '$1', want '$2')"; fi; }
assert_contains() { case "$1" in *"$2"*) pass "$3" ;; *) fail "$3 (missing '$2')" ;; esac; }
assert_not_contains() { case "$1" in *"$2"*) fail "$3 (unexpected '$2')" ;; *) pass "$3" ;; esac; }
assert_file() { if [ -s "$1" ]; then pass "$2"; else fail "$2 (no file $1)"; fi; }
# Usage: assert_exit <want> <label> <cmd...>
assert_exit() {
  local want=$1 label=$2 rc
  shift 2
  set +e; "$@" >/dev/null 2>&1; rc=$?; set -e
  assert_eq "$rc" "$want" "$label"
}
gc() { git -c user.name=t -c user.email=t@t commit -q "$@"; }
mk_repo() {
  local d
  d=$(mktemp -d)
  git -C "$d" init -q
  git -C "$d" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
  printf '%s\n' "$d"
}
finish() { if [ "$FAILS" -ne 0 ]; then echo "$FAILS failure(s)" >&2; exit 1; fi; }
