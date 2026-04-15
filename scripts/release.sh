#!/usr/bin/env bash
# scripts/release.sh — Bump version, commit, tag, and push to trigger a release.
#
# Usage:
#   ./scripts/release.sh <version>          # e.g., ./scripts/release.sh 0.7.0
#   ./scripts/release.sh --dry-run <version> # preview without side effects

set -euo pipefail

DRY_RUN=false
VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) VERSION="$1"; shift ;;
  esac
done

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 [--dry-run] <version>" >&2
  echo "Example: $0 0.7.0" >&2
  exit 1
fi

# Validate version format (semver with optional pre-release)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$'; then
  echo "Error: Invalid version format '$VERSION'. Expected semver (e.g., 0.7.0 or 0.7.0-beta.1)" >&2
  exit 1
fi

TAG="v${VERSION}"
PLUGIN_JSON=".claude-plugin/plugin.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

# Check for uncommitted changes (ignore .claude/ session files)
if ! git diff --quiet -- ':!.claude/' || ! git diff --cached --quiet -- ':!.claude/'; then
  echo "Error: Working tree has uncommitted changes. Commit or stash them first." >&2
  exit 1
fi

# Check that tag doesn't already exist
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Error: Tag '$TAG' already exists." >&2
  exit 1
fi

# Read current version
CURRENT_VERSION=$(jq -r '.version' "$PLUGIN_JSON")

echo "Release: $CURRENT_VERSION -> $VERSION ($TAG)"

if $DRY_RUN; then
  echo "[dry-run] Would update $PLUGIN_JSON version to $VERSION"
  echo "[dry-run] Would commit: chore: bump version to $VERSION"
  echo "[dry-run] Would create tag: $TAG"
  echo "[dry-run] Would push tag to origin"
  exit 0
fi

# Update plugin.json version
jq --arg v "$VERSION" '.version = $v' "$PLUGIN_JSON" > "${PLUGIN_JSON}.tmp"
mv "${PLUGIN_JSON}.tmp" "$PLUGIN_JSON"

# Commit and tag
git add "$PLUGIN_JSON"
git commit -m "chore: bump version to $VERSION"
git tag "$TAG"

# Push commit and tag
git push origin HEAD
git push origin "$TAG"

echo "Done! Tag $TAG pushed. GitHub Actions will create the release."
