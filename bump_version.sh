#!/bin/bash

# Arguments: existing repo URL and new repo URL
EXISTING_REPO_URL=$1
NEW_REPO_URL=$2

STANDARD_INITIAL_VERSION="0.0.1"

# Clone the existing repository
echo "Cloning the existing repository: $EXISTING_REPO_URL"
git clone "$EXISTING_REPO_URL" new-repo
cd new-repo

# Reinitialize the repository (remove the old Git history)
echo "Reinitializing the repository..."
rm -rf .git
git init

# Set the initial version in a version.txt file
echo "$STANDARD_INITIAL_VERSION" > version.txt
git add version.txt
git commit -m "Set initial version to $STANDARD_INITIAL_VERSION"

# Add the new repository as remote and push
git remote add origin "$NEW_REPO_URL"
git branch -M develop
git push -u origin develop
