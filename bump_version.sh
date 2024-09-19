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

# Variables for existing and new repository URLs
EXISTING_REPO_URL=$1
NEW_REPO_URL=$2

echo "Cloning the existing repository: $EXISTING_REPO_URL"

# Clone the existing repository into a new directory
git clone "$EXISTING_REPO_URL" new-repo || { echo "Failed to clone $EXISTING_REPO_URL"; exit 1; }

# Move into the newly created directory
cd new-repo || { echo "Failed to enter new-repo directory"; exit 1; }

# Remove the existing .git directory and reinitialize the Git repository
echo "Reinitializing the repository..."
rm -rf .git && git init || { echo "Failed to initialize new git repo"; exit 1; }

# Configure Git user name and email (passed via GitHub Actions environment)
git config user.email "${GIT_USER_EMAIL}"
git config user.name "${GIT_USER_NAME}"

# Create a version file with an initial version
STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Ensure the develop branch exists or create it if it doesn't
git checkout -b develop || git checkout develop || { echo "Failed to create or switch to develop branch"; exit 1; }

# Add all files to the staging area
echo "Staging files..."
git add . || { echo "Failed to stage files"; exit 1; }

# Commit the changes, and if nothing is staged, echo a message
if git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION"; then
  echo "Commit successful"
else
  echo "Nothing to commit. Exiting script."
  exit 1
fi

# Add the new remote repository URL
echo "Adding the new remote repository: $NEW_REPO_URL"
git remote add origin "$NEW_REPO_URL" || { echo "Failed to add remote $NEW_REPO_URL"; exit 1; }

# Push the changes to the 'develop' branch
echo "Pushing changes to the new repository..."
git push -u origin develop || { echo "Failed to push to the new repository"; exit 1; }

echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
