#!/bin/bash
# Function
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

git clone "$EXISTING_REPO_URL" gh-skeleton-new && cd gh-skeleton-new
rm -rf .git && git init

STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION"

# Add a tag with the new version v0.0.1
git tag "v$STANDARD_INITIAL_VERSION"

git remote add origin "$NEW_REPO_URL"
git push -u origin develop
git push origin "v$STANDARD_INITIAL_VERSION"

# Output the new version
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
