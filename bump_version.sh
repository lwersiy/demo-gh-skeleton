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

# Clone the existing repository into a new directory
git clone "$EXISTING_REPO_URL" new-gh-skeleton || { echo "Failed to clone $EXISTING_REPO_URL"; exit 1; }

# Move into the newly created directory
cd new-gh-skeleton || { echo "Failed to enter new-gh-skeleton directory"; exit 1; }

# Remove the existing .git directory and reinitialize the Git repository
rm -rf .git && git init || { echo "Failed to initialize new git repo"; exit 1; }

# Verify that files are present in the directory
echo "Verifying files in directory..."
ls -al

# Create a version file with an initial version if needed
STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Ensure the develop branch exists or create it if it doesn't
git checkout -b develop || git checkout develop || { echo "Failed to create or switch to develop branch"; exit 1; }

# Add all files to the staging area
git add .

# Check the status to verify that files are staged
git status

# Commit the changes, and if nothing is staged, echo a message
if git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION"; then
  echo "Commit successful"
else
  echo "Nothing to commit"
fi

# Add the new remote repository URL
git remote add origin "$NEW_REPO_URL" || { echo "Failed to add remote $NEW_REPO_URL"; exit 1; }

# Push the changes to the 'develop' branch and handle errors
if git push -u origin develop; then
  echo "Develop branch pushed successfully"
else
  echo "Failed to push develop branch"
fi

# Push the tags if there are any
if git push --tags; then
  echo "Tags pushed successfully"
else
  echo "Failed to push tags"
fi

# Output the result
echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
