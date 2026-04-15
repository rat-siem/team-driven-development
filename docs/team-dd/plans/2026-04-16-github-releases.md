# GitHub Releases Automation Implementation Plan

> **For agentic workers:** Use team-driven-development to execute this plan.

**Goal:** Automate GitHub Release creation via GitHub Actions, triggered by version tags.

**Architecture:** A GitHub Actions workflow triggers on `v*` tag pushes, validates tag/version consistency, and creates a release with auto-generated notes. A shell script handles the full release flow (version bump, commit, tag, push).

**Tech Stack:** GitHub Actions, shell script, `gh` CLI, `jq`

---

## File Structure

| Action | Path | Purpose |
|--------|------|---------|
| Create | `.github/workflows/release.yml` | GitHub Actions release workflow |
| Create | `scripts/release.sh` | Release helper script |

---

### Task 1: GitHub Actions Release Workflow

**Files:**
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: Create the workflow file**

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate tag matches plugin.json version
        run: |
          TAG_VERSION="${GITHUB_REF_NAME#v}"
          PLUGIN_VERSION=$(jq -r '.version' .claude-plugin/plugin.json)
          if [ "$TAG_VERSION" != "$PLUGIN_VERSION" ]; then
            echo "::error::Tag version ($TAG_VERSION) does not match plugin.json version ($PLUGIN_VERSION)"
            exit 1
          fi
          echo "Version validated: $TAG_VERSION"

      - name: Determine pre-release
        id: prerelease
        run: |
          if echo "$GITHUB_REF_NAME" | grep -qE '-(alpha|beta|rc)'; then
            echo "flag=--prerelease" >> "$GITHUB_OUTPUT"
          else
            echo "flag=" >> "$GITHUB_OUTPUT"
          fi

      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release create "$GITHUB_REF_NAME" \
            --title "$GITHUB_REF_NAME" \
            --generate-notes \
            ${{ steps.prerelease.outputs.flag }}
```

- [ ] **Step 2: Commit**
```bash
git add .github/workflows/release.yml
git commit -m "feat: add GitHub Actions release workflow"
```

---

### Task 2: Release Script

**Files:**
- Create: `scripts/release.sh`

- [ ] **Step 1: Create the release script**

```bash
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

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
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
```

- [ ] **Step 2: Make executable**
```bash
chmod +x scripts/release.sh
```

- [ ] **Step 3: Commit**
```bash
git add scripts/release.sh
git commit -m "feat: add release helper script"
```

---

### Task 3: Retroactive Tags for Existing Versions

Create tags for all previously released versions to establish history for `--generate-notes`.

- [ ] **Step 1: Create tags pointing to version-bump commits**
```bash
git tag v0.2.0 a7a3973
git tag v0.3.0 c771564
git tag v0.4.0 3ce1e13
git tag v0.5.0 798dced
git tag v0.6.0 f8ee750
git tag v0.6.1 e0d5daa
```

- [ ] **Step 2: Push all tags**
```bash
git push origin --tags
```

- [ ] **Step 3: Commit (no file changes — tags only)**
No commit needed. Tags are pushed directly.

---

### Task 4: Verify End-to-End

- [ ] **Step 1: Verify tags appear on GitHub**
```bash
gh api repos/:owner/:repo/tags --jq '.[].name'
```

- [ ] **Step 2: Test release script dry-run**
```bash
./scripts/release.sh --dry-run 0.7.0
```

- [ ] **Step 3: Verify workflow file is valid**
```bash
gh workflow list
```
The `Release` workflow should appear in the list (only visible after pushing to the default branch).
