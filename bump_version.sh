git clone "$EXISTING_REPO_URL" gh-skeleton-new && cd gh-skeleton-new
rm -rf .git && git init

STANDARD_INITIAL_VERSION="0.0.1"
echo "$STANDARD_INITIAL_VERSION" > version.txt

git add .
git commit -m "Initial commit with version $STANDARD_INITIAL_VERSION"

# Ensure branch develop exists before pushing
git checkout -b develop

# Add a tag with the new version v0.0.1
git tag "v$STANDARD_INITIAL_VERSION"

git remote add origin "$NEW_REPO_URL"
git push -u origin develop
git push origin "v$STANDARD_INITIAL_VERSION"
