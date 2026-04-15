# GitHub Releases Automation Design

## Overview

Automate GitHub release creation using GitHub Actions. When a version tag (`v*`) is pushed, a workflow automatically creates a GitHub Release with auto-generated release notes from commit history.

## Motivation

- No formal release process exists — versions are tracked only via commit messages
- No git tags exist for any released version (0.2.0 through 0.6.1)
- Users and contributors have no way to see what changed between versions
- Manual release creation is error-prone and easy to forget

## Design

### Release Trigger

The workflow triggers on tag pushes matching the pattern `v*` (e.g., `v0.7.0`).

This keeps the existing version-bump commit workflow intact — the only addition is pushing a tag after the commit.

### GitHub Actions Workflow

A single workflow file `.github/workflows/release.yml`:

1. **Trigger:** `on: push: tags: ['v*']`
2. **Steps:**
   - Checkout the repository
   - Validate that the tag version matches `plugin.json` version (safety check)
   - Create a GitHub Release using `gh release create` with `--generate-notes`

GitHub's `--generate-notes` auto-generates release notes from commit messages and PR titles since the previous tag. This avoids maintaining a separate CHANGELOG file.

### Version-Tag Consistency Check

The workflow validates that the pushed tag (e.g., `v0.7.0`) matches the version in `.claude-plugin/plugin.json` (e.g., `0.7.0`). If they don't match, the workflow fails with a clear error message. This prevents accidental tag/version mismatches.

### Release Script

A helper script `scripts/release.sh` streamlines the release process:

```
./scripts/release.sh 0.7.0
```

This script:
1. Updates the version in `.claude-plugin/plugin.json`
2. Creates the version-bump commit (`chore: bump version to 0.7.0`)
3. Creates and pushes the git tag (`v0.7.0`)
4. The tag push triggers the GitHub Actions workflow automatically

### Retroactive Tags

Create git tags for all existing versions (0.2.0 through 0.6.1) pointing to their respective bump commits. This establishes a complete version history and enables `--generate-notes` to work correctly for the first new release.

### Pre-release Support

Tags containing `-alpha`, `-beta`, or `-rc` (e.g., `v0.7.0-beta.1`) are automatically marked as pre-releases in the GitHub Release.

## Error Handling

- **Tag/version mismatch:** Workflow fails with message showing expected vs actual version
- **Tag without corresponding commit:** Git prevents this naturally (tags point to commits)
- **Release script on dirty worktree:** Script aborts if uncommitted changes exist

## Testing Strategy

- Validate the release script locally (dry-run mode with `--dry-run` flag)
- Test the GitHub Actions workflow by pushing a tag to the repository
- Verify retroactive tags appear correctly in GitHub's releases/tags UI

## File Changes

| Action | Path | Purpose |
|--------|------|---------|
| Create | `.github/workflows/release.yml` | GitHub Actions release workflow |
| Create | `scripts/release.sh` | Release helper script |
| None | `.claude-plugin/plugin.json` | Read for version validation (modified by release script at release time) |
