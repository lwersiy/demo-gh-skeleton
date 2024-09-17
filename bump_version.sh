#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 <existing-repo-url> <new-repo-url> [<branch>]"
  echo "Example: $0 https://github.com/user/existing-repo.git https://github.com/user/new-repo.git develop"
  exit 1
}

# Check if Git is installed
if ! command -v git &> /dev/null; then
  echo "Error: Git is not installed. Please install Git and try again."
  exit 1
fi

# Check for proper arguments
if [ "$#" -lt 2 ]; then
  usage
fi

EXISTING_REPO_URL=$1
NEW_REPO_URL=$2
BRANCH=${3:-develop}  # Default to 'develop' branch if not provided

# Clone the existing repository
if ! git clone "$EXISTING_REPO_URL" gh-skeleton-new; then
  echo "Error: Failed to clone repository from $EXISTING_REPO_URL"
  exit 1
fi

cd gh-skeleton-new || { echo "Error: Directory gh-skeleton-new does not exist"; exit 1; }

# Remove old git history and reinitialize a new repository
rm -rf .git && git init

# Check if initialization succeeded
if [ $? -ne 0 ]; then
  echo "Error: Git initialization failed."
  exit 1
fi

# Set up the default branch (allow custom branch input)
git checkout -b "$BRANCH" || { echo "Error: Failed to create and switch to branch $BRANCH"; exit 1; }

# Create a version file with an initial version
STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Add all files and commit
git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION" || { echo "Error: Commit failed"; exit 1; }

# Add a tag with the new version v0.0.1
git tag "v$STANDARD_INITIAL_VERSION" || { echo "Error: Failed to create tag"; exit 1; }

# Add the new remote repository
git remote add origin "$NEW_REPO_URL" || { echo "Error: Failed to add remote $NEW_REPO_URL"; exit 1; }

# Push the 'develop' branch and the tag to the new repository
git push -u origin "$BRANCH" || { echo "Error: Failed to push to branch $BRANCH"; exit 1; }
git push origin "v$STANDARD_INITIAL_VERSION" || { echo "Error: Failed to push tag v$STANDARD_INITIAL_VERSION"; exit 1; }

# Output the new version and success message
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION on branch $BRANCH"
