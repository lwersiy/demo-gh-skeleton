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

# Clone the existing repo into a directory named gh-skeleton-new
git clone "$EXISTING_REPO_URL" gh-skeleton-new && cd gh-skeleton-new

# Remove the existing .git history and initialize a fresh git repo
rm -rf .git && git init

# Set the standard initial version to v0.0.1
STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Commit the new initial version to the repo
git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION"

# Add a tag with the new version v0.0.1
git tag "v$STANDARD_INITIAL_VERSION"

# Add the new remote repository URL
git remote add origin "$NEW_REPO_URL"

# Push the initial commit and tag to the 'develop' branch of the new repo
git push -u origin develop
git push origin "v$STANDARD_INITIAL_VERSION"

# Output the new version
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
