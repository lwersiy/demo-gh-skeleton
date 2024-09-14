#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 existing-repo-url new-repo-url"
  exit 1
}

# Function to check if the tag exists in the remote repository
check_tag_exists() {
  git ls-remote --tags "$NEW_REPO_URL" | grep "refs/tags/v$STANDARD_INITIAL_VERSION" &> /dev/null
}

# Function to delete the existing tag in the remote repo
delete_remote_tag() {
  git push origin --delete "v$STANDARD_INITIAL_VERSION"
}

# Function to check if the repository exists
check_repo_exists() {
  git ls-remote "$NEW_REPO_URL" &> /dev/null
}

# Check for proper arguments
if [ "$#" -lt 2 ]; then
  usage
fi

EXISTING_REPO_URL=$1
NEW_REPO_URL=$2

# Clone the existing repo and start fresh
git clone "$EXISTING_REPO_URL" new-gh-skeleton-repo || { echo "Cloning failed!"; exit 1; }
cd new-gh-skeleton-repo || { echo "Failed to enter directory!"; exit 1; }

# Remove Git history and reinitialize
rm -rf .git && git init || { echo "Failed to initialize repo!"; exit 1; }

# Set the version to a new standard initial version
STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Commit the new initial version to the repo
git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION" || { echo "Commit failed!"; exit 1; }

# Add the new remote repository
git remote add origin "$NEW_REPO_URL"

# Verify remote URL is set correctly
REMOTE_URL=$(git remote get-url origin)
if [ -z "$REMOTE_URL" ]; then
  echo "Error: Remote URL 'origin' not set properly."
  exit 1
fi

# Test connection to the remote repository
if ! git ls-remote "$NEW_REPO_URL" &> /dev/null; then
  echo "Error: Could not connect to the remote repository at $NEW_REPO_URL."
  exit 1
fi

# Check if the tag already exists in the remote repo
if check_tag_exists; then
  echo "Tag v$STANDARD_INITIAL_VERSION already exists in the remote repository."

  # Prompt user for action: Delete the tag or increment version
  read -p "Do you want to delete the existing tag from the remote repository? (y/n): " choice
  if [ "$choice" = "y" ]; then
    echo "Deleting existing tag v$STANDARD_INITIAL_VERSION from the remote repository..."
    delete_remote_tag || { echo "Failed to delete the tag from the remote!"; exit 1; }
  else
    read -p "Enter a new version number (e.g., 0.0.2): " NEW_VERSION
    STANDARD_INITIAL_VERSION=$NEW_VERSION
    echo "Setting new version: v$STANDARD_INITIAL_VERSION"
  fi
fi

# Add a tag with the (new or initial) version
git tag "v$STANDARD_INITIAL_VERSION"

# Push the initial commit and tag to the new remote repository
if ! git push -u origin develop; then
  echo "Pushing to develop failed! Checking for updates..."
  git fetch origin
  git merge origin/develop || { echo "Failed to merge changes from remote!"; exit 1; }
  git push -u origin develop || { echo "Failed to push after merging!"; exit 1; }
fi

# Push the tag
if ! git push origin "v$STANDARD_INITIAL_VERSION"; then
  echo "Pushing tag failed! Checking for tag conflicts..."
  git push origin --delete "v$STANDARD_INITIAL_VERSION" || { echo "Failed to delete conflicting tag!"; exit 1; }
  git push origin "v$STANDARD_INITIAL_VERSION" || { echo "Failed to push new tag!"; exit 1; }
fi

# Output the new version
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
