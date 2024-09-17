#!/bin/bash

# Function to display usage information
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

# Clone the existing repository
git clone "$EXISTING_REPO_URL" new-gh-skeleton && cd new-gh-skeleton

# Remove old git history and reinitialize a new repository
rm -rf .git && git init

# Set up the default branch to 'develop' instead of 'master'
git checkout -b develop

# Create a version file with an initial version
STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Add all files and commit
git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION" || echo "Nothing to commit"

# Add a tag with the new version v0.0.1
git tag "v$STANDARD_INITIAL_VERSION"

# Add the new remote repository
git remote add origin "$NEW_REPO_URL"

# Push the 'develop' branch and the tag to the new repository
git push -u origin develop
git push origin "v$STANDARD_INITIAL_VERSION"

# Output the new version
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
