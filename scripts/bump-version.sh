#!/bin/bash
set -e

# Script to bump version and create git tag
# Usage: ./scripts/bump-version.sh [major|minor|patch]

VERSION_FILE="VERSION"
BUMP_TYPE="${1:-patch}"

if [ ! -f "$VERSION_FILE" ]; then
    echo "Error: $VERSION_FILE not found"
    exit 1
fi

# Read current version
CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')

# Parse version components
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Increment based on type
case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Error: Invalid bump type. Use 'major', 'minor', or 'patch'"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"
echo ""

# Confirm with user
read -p "Create version $NEW_VERSION and tag v$NEW_VERSION? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted"
    exit 0
fi

# Update VERSION file
echo "$NEW_VERSION" > "$VERSION_FILE"

# Git operations
git add "$VERSION_FILE"
git commit -m "Bump version to $NEW_VERSION"
git tag "v$NEW_VERSION"

echo ""
echo "Version bumped to $NEW_VERSION"
echo "Tag v$NEW_VERSION created"
echo ""
echo "To push the changes and trigger the build, run:"
echo "  git push origin master && git push origin v$NEW_VERSION"
