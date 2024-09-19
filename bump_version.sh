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

echo "Cloning the existing repository: $EXISTING_REPO_URL"

git clone "$EXISTING_REPO_URL" gh-skeleton-two || { echo "Failed to clone $EXISTING_REPO_URL"; exit 1; }

cd gh-skeleton-two || { echo "Failed to enter gh-skeleton-two directory"; exit 1; }

echo "Listing files in gh-skeleton-two directory:"
ls -al  # Ensure the cloned files are present

# Remove the existing .git directory and reinitialize the Git repository
echo "Reinitializing the repository..."
rm -rf .git && git init || { echo "Failed to initialize new git repo"; exit 1; }

git config user.email "$GIT_USER_EMAIL"
git config user.name "$GIT_USER_NAME"

if [ -f ".gitignore" ]; then
  echo "Found .gitignore file. Contents:"
  cat .gitignore
fi

# Create a version file with an initial version
STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

# Ensure the develop branch exists or create it if it doesn't
git checkout -b develop || git checkout develop || { echo "Failed to create or switch to develop branch"; exit 1; }

# Add all files to the staging area
echo "Staging files..."
git add . || { echo "Failed to stage files"; exit 1; }
git status

# Commit the changes, and if nothing is staged, echo a message
if git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION"; then
  echo "Commit successful"
else
  echo "Nothing to commit. Exiting script."
  exit 1
fi

# Add the new remote repository URL
git remote add origin "$NEW_REPO_URL" || { echo "Failed to add remote $NEW_REPO_URL"; exit 1; }

# Use the MY_PAT token for authentication by modifying the remote URL
git remote set-url origin "https://${MY_PAT}@github.com/${NEW_REPO_URL#https://github.com/}"

# Push the changes to the 'develop' branch, handling potential push failures
echo "Pushing the develop branch to the new repository..."
if git push -u origin develop; then
  echo "Develop branch pushed successfully"
else
  echo "Failed to push develop branch"
  exit 1
fi

# Push the tags if there are any
echo "Pushing tags..."
if git push --tags; then
  echo "Tags pushed successfully"
else
  echo "Failed to push tags"
fi

echo "Repository cloned, cleaned, and initialized with version $STANDARD_INITIAL_VERSION"
