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
PRE_RELEASE_DIR="/home/ubuntu_huawei/wordpress-docker/common/pre-release-plugin"
SOURCE_FOLDER="/home/ubuntu_huawei/wordpress-docker/instances/kymvex-inv-alert/plugin/kymvex-inv-alert"
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

# 3.5) Adjust file ownership and permissions
echo "Adjusting file ownership and permissions for '$DEST_FOLDER'..."
chown -R ubuntu_huawei:ubuntu_huawei "$DEST_FOLDER"
find "$DEST_FOLDER" -type d -exec chmod 755 {} +
find "$DEST_FOLDER" -type f -exec chmod 644 {} +
echo "Ownership set to ubuntu_huawei:ubuntu_huawei, directories to 755, files to 644."

# 4) If .gitattributes exists, parse export-ignore patterns
if [[ -f "$GITATTR_FILE" ]]; then
    echo "Parsing .gitattributes in $GITATTR_FILE for export-ignore rules..."
    while IFS= read -r line; do
        # Skip blank lines
        [[ -z "$line" ]] && continue
        # Skip lines that don't have "export-ignore"
        [[ "$line" != *"export-ignore"* ]] && continue

        pattern="$(echo "$line" | awk '{print $1}')"
        stripped_pattern="${pattern#/}"
        stripped_pattern="${stripped_pattern%/}"

        echo "Removing pattern: $pattern (interpreted as $stripped_pattern)"
        if [[ "$stripped_pattern" == *"*"* ]]; then
            # If pattern has wildcards, remove matching files and directories
            find "$DEST_FOLDER" -type f -name "$stripped_pattern" -exec rm -f {} +
            find "$DEST_FOLDER" -type d -name "$stripped_pattern" -exec rm -rf {} +
        else
            # Remove exact file or folder matches
            find "$DEST_FOLDER" -path "*/$stripped_pattern" -exec rm -rf {} +
        fi
    done < <(grep 'export-ignore' "$GITATTR_FILE")
else
    echo "No .gitattributes file found at $GITATTR_FILE; skipping export-ignore parsing."
fi

# 4.5) Remove everything under vendor/ except autoload.php
#      And remove composer.phar in plugin root
if [[ -d "$DEST_FOLDER/vendor" ]]; then
    echo "Removing everything in '$DEST_FOLDER/vendor' except autoload.php..."
    cd "$DEST_FOLDER/vendor"
    find . -mindepth 1 ! -name 'autoload.php' -exec rm -rf {} +
    cd - > /dev/null
fi

# Remove composer.phar if it exists in the plugin root
if [[ -f "$DEST_FOLDER/composer.phar" ]]; then
    echo "Removing '$DEST_FOLDER/composer.phar'..."
    rm -f "$DEST_FOLDER/composer.phar"
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

# 8) Display final instructions about Git tagging (manual push)
echo "Release branch '$BRANCH_NAME' created locally."
echo
echo "To push this release to GitHub manually, do:"
echo "  git push -u origin $BRANCH_NAME"
echo
echo "You can then create a new release with the following tag:"
echo "  git tag -a v$RELEASE_VERSION -m 'Release version $RELEASE_VERSION'"
echo "  git push origin v$RELEASE_VERSION"

# 9) Create plugin ZIP for distribution (one level above $DEST_FOLDER)
cd ..
ZIP_NAME="kymvex-inv-alert.zip"

echo "Zipping '$PLUGIN_INSTANCE' into '$ZIP_NAME' for final distribution..."
zip -r "$ZIP_NAME" "$PLUGIN_INSTANCE"

# Confirm the zip file is created
echo "Created ZIP file at: $(pwd)/$ZIP_NAME"
echo "Script completed."
