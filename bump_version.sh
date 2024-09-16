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

# Clone the existing repo into a directory named gh-skeleton-new
echo "Cloning the existing repository from $EXISTING_REPO_URL..."
git clone "$EXISTING_REPO_URL" gh-skeleton-new

# Check if the cloning was successful
if [ ! -d "gh-skeleton-new" ]; then
  echo "Cloning failed or directory 'gh-skeleton-new' was not created."
  exit 1
fi

# Change to the repository directory
cd gh-skeleton-new || { echo "Failed to enter the 'gh-skeleton-new' directory."; exit 1; }

# Remove existing git metadata and initialize a new repository
# echo "Reinitializing repository..."
# rm -rf .git
# git init

# Set the standard initial version
STANDARD_INITIAL_VERSION="0.0.1"

# Output the initial version to a file
echo "Using version: v$STANDARD_INITIAL_VERSION"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Stage and commit the new version
git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION"

# Add a tag with the initial version
git tag "v$STANDARD_INITIAL_VERSION"

# Add the new remote repository
echo "Adding new remote repository..."
git remote add origin "$NEW_REPO_URL"

# Create and switch to the 'develop' branch
git checkout -b develop

# Push the initial commit and tag to the new remote repository
echo "Pushing to the new repository..."
git push -u origin develop
git push origin "v$STANDARD_INITIAL_VERSION"

# Output the new version
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
