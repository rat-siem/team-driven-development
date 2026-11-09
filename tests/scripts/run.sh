#!/usr/bin/env bash
# Run every tests/scripts/test-*.sh; exit 1 if any fails.
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
status=0
for t in "$here"/test-*.sh; do
  echo "== $(basename "$t")"
  bash "$t" || status=1
done
exit $status
