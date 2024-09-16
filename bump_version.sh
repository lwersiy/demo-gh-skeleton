#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 existing-repo-url new-repo-url"
  exit 1
}

# Check for proper arguments
if [ "$#" -lt 2 ]; then
  usage
fi

EXISTING_REPO_URL=$1
NEW_REPO_URL=$2

# Clone the existing repo into a directory named new-repo-from-action
git clone "$EXISTING_REPO_URL" gh-skeleton-new && cd gh-skeleton-new && rm -rf .git && git init

# Function to increment version
increment_version() {
  local version=$1
  local major minor patch
  IFS='.' read -r major minor patch <<< "$version"
  patch=$((patch + 1))
  echo "$major.$minor.$patch"
}

# Set the standard initial version
STANDARD_INITIAL_VERSION="0.0.1"
CURRENT_VERSION=$STANDARD_INITIAL_VERSION

# Check if the tag already exists in the new repository
git ls-remote --tags "$NEW_REPO_URL" | grep -q "refs/tags/v$CURRENT_VERSION"

while [ $? -eq 0 ]; do
  echo "Version v$CURRENT_VERSION already exists, incrementing..."
  CURRENT_VERSION=$(increment_version "$CURRENT_VERSION")
  git ls-remote --tags "$NEW_REPO_URL" | grep -q "refs/tags/v$CURRENT_VERSION"
done

# Output the new version
echo "Using version: v$CURRENT_VERSION"
echo "$CURRENT_VERSION" > version.txt

# Commit the new initial version to the repo
git add .
git commit -m "Initial commit with version $CURRENT_VERSION"

# Add a tag with the new version
git tag "v$CURRENT_VERSION"

# Add the new remote repository
git remote add origin "$NEW_REPO_URL"

# Push the initial commit and tag to the new remote repository on the 'develop' branch
git push -u origin develop
git push origin "v$CURRENT_VERSION"

# Output the new version
echo "Repository cloned, cleaned, and initialized with version $CURRENT_VERSION"
