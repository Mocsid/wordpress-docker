#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME=$(basename "$0")

usage() {
    echo "Usage: $SCRIPT_NAME <plugin_instance> <release_version>"
    exit 1
}

if [[ $# -ne 2 ]]; then
    echo "Error: Two arguments are required: <plugin_instance> <release_version>"
    usage
fi

PLUGIN_INSTANCE="$1"
RELEASE_VERSION="$2"

# Paths
PRE_RELEASE_DIR="$HOME/wordpress-docker/common/pre-release-plugin"
SOURCE_FOLDER="$HOME/wordpress-docker/instances/${PLUGIN_INSTANCE}/plugin/${PLUGIN_INSTANCE}"
DEST_FOLDER="$PRE_RELEASE_DIR/$PLUGIN_INSTANCE"
GITATTR_FILE="$SOURCE_FOLDER/.gitattributes"  # Adjust if your .gitattributes is located elsewhere

# GitHub repository URL
GITHUB_REPO="https://github.com/Kymvex/kymvex-inv-alert.git"

# 1) Remove old pre-release content
echo "Removing all contents under $PRE_RELEASE_DIR..."
rm -rf "${PRE_RELEASE_DIR:?}"/*
echo "Cleanup done. $PRE_RELEASE_DIR is now empty."

# 2) Ensure plugin source folder exists
if [[ ! -d "$SOURCE_FOLDER" ]]; then
    echo "Error: Plugin source folder not found at $SOURCE_FOLDER"
    exit 1
fi

# 3) Copy plugin folder to pre-release
echo "Copying $SOURCE_FOLDER to $DEST_FOLDER..."
mkdir -p "$DEST_FOLDER"
cp -R "$SOURCE_FOLDER/." "$DEST_FOLDER"

# 4) If .gitattributes exists, parse export-ignore patterns
if [[ -f "$GITATTR_FILE" ]]; then
    echo "Parsing .gitattributes in $GITATTR_FILE for export-ignore rules..."
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        [[ "$line" != *"export-ignore"* ]] && continue
        
        pattern="$(echo "$line" | awk '{print $1}')"
        stripped_pattern="${pattern#/}"
        stripped_pattern="${stripped_pattern%/}"

        echo "Removing pattern: $pattern (interpreted as $stripped_pattern)"
        if [[ "$stripped_pattern" == *"*"* ]]; then
            find "$DEST_FOLDER" -type f -name "$stripped_pattern" -exec rm -f {} +
            find "$DEST_FOLDER" -type d -name "$stripped_pattern" -exec rm -rf {} +
        else
            find "$DEST_FOLDER" -path "*/$stripped_pattern" -exec rm -rf {} +
        fi
    done < <(grep 'export-ignore' "$GITATTR_FILE")
else
    echo "No .gitattributes file found at $GITATTR_FILE; skipping export-ignore parsing."
fi

echo "Final pre-release directory: $DEST_FOLDER"
ls -R "$DEST_FOLDER"

# 5) Initialize Git repository if not already initialized
cd "$DEST_FOLDER"
if [[ ! -d ".git" ]]; then
    echo "Initializing new Git repository..."
    git init
    git remote add origin "$GITHUB_REPO"
else
    echo "Git repository already initialized."
fi

# 6) Create and switch to a new release branch
BRANCH_NAME="release-v$RELEASE_VERSION"
git checkout -b "$BRANCH_NAME" || git checkout "$BRANCH_NAME"

# 7) Add and commit all changes
echo "Committing changes..."
git add .
git commit -m "Prepare release v$RELEASE_VERSION"

# 8) Push the branch to GitHub
echo "Pushing branch to GitHub..."
git push -u origin "$BRANCH_NAME"

# 9) Display final instructions
echo "Release branch pushed to GitHub. You can now create a new release using the following tag:"
echo "Tag: v$RELEASE_VERSION"
echo "Run the following to create the tag and push it:"
echo "git tag -a v$RELEASE_VERSION -m 'Release version $RELEASE_VERSION'"
echo "git push origin v$RELEASE_VERSION"
