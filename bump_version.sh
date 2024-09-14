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

# Always set the version to a new standard initial version (e.g., 0.0.1)
STANDARD_INITIAL_VERSION="0.0.1"

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

echo "$STANDARD_INITIAL_VERSION" > version.txt

# Commit the new initial version to the repo
git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION" || { echo "Commit failed!"; exit 1; }

# Add a tag with the (new or initial) version
git tag "v$STANDARD_INITIAL_VERSION"

# Add the new remote repository
git remote add origin "$NEW_REPO_URL"

# Push the initial commit and tag to the new remote repository
git push -u origin master || { echo "Pushing to master failed!"; exit 1; }
git push origin "v$STANDARD_INITIAL_VERSION" || { echo "Pushing tag failed!"; exit 1; }

# Output the new version
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"

# # To run this script, first make it executable:
# "chmod +x bump_version.sh"
# # Run the script with the existing URL and the new URL:
# "./bump_version.sh https://github.com/username/existing-repo.git https://github.com/your-username/new-repo.git"
