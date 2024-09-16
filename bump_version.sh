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

# Clone the existing repo into a directory named gh-skeleton
git clone "$EXISTING_REPO_URL" gh-skeleton && cd gh-skeleton && rm -rf .git && git init

# Set the standard initial version
STANDARD_INITIAL_VERSION="0.0.1"

# Output the initial version
echo "Using version: v$STANDARD_INITIAL_VERSION"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Commit the new initial version to the repo
git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION"

# Add a tag with the initial version
git tag "v$STANDARD_INITIAL_VERSION"

# Add the new remote repository
git remote add origin "$NEW_REPO_URL"

# Push the initial commit and tag to the new remote repository on the 'develop' branch
git checkout -b develop
git push -u origin develop
git push origin "v$STANDARD_INITIAL_VERSION"

# Output the new version
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
