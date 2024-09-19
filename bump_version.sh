#!/bin/bash

# Arguments: source repo and new repo name
SOURCE_REPO=$1
NEW_REPO=$2

# Validate inputs
if [ -z "$SOURCE_REPO" ] || [ -z "$NEW_REPO" ]; then
  echo "Usage: $0 <source-repo> <new-repo-name>"
  exit 1
fi

# Clone the existing repository
echo "Cloning repository $SOURCE_REPO into $NEW_REPO..."
gh repo clone "lwersiy/$SOURCE_REPO" $NEW_REPO

# Navigate into the cloned repository
cd $NEW_REPO || exit

# Remove the Git history to reinitialize it as a fresh repository
echo "Removing Git history..."
rm -rf .git

# Reinitialize the repository as a fresh Git repository
echo "Reinitializing the repository..."
git init

# Create a version file with STANDARD_INITIAL_VERSION
STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt
git add version.txt
git commit -m "Set initial version to $STANDARD_INITIAL_VERSION"

# Create a new repository on GitHub using the GitHub CLI
echo "Creating new repository on GitHub: $NEW_REPO..."
gh repo create lwersiy/$NEW_REPO --public --confirm

# Add the new remote repository
echo "Adding new repository as remote..."
git remote add origin https://github.com/lwersiy/$NEW_REPO.git

# Push to the develop branch instead of main
echo "Pushing the repository to GitHub on the develop branch..."
git branch -M develop
git push -u origin develop

echo "Repository $NEW_REPO created and pushed successfully on the develop branch."
