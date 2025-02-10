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

# Where to copy the final ZIP on Windows (if using WSL)
WINDOWS_RELEASE_FOLDER="/mnt/c/Users/marlo/Desktop/kymvex-inv-alert-releases"

################################################################################
# 1) Remove old pre-release content
################################################################################
echo "Removing all contents under $PRE_RELEASE_DIR..."
rm -rf "${PRE_RELEASE_DIR:?}"/*
echo "Cleanup done. $PRE_RELEASE_DIR is now empty."

################################################################################
# 2) Ensure plugin source folder exists
################################################################################
if [[ ! -d "$SOURCE_FOLDER" ]]; then
    echo "Error: Plugin source folder not found at $SOURCE_FOLDER"
    exit 1
fi

################################################################################
# 3) Copy plugin folder to pre-release
################################################################################
echo "Copying $SOURCE_FOLDER to $DEST_FOLDER..."
mkdir -p "$DEST_FOLDER"
cp -R "$SOURCE_FOLDER/." "$DEST_FOLDER"

################################################################################
# 3.5) Adjust file ownership and permissions
################################################################################
echo "Adjusting file ownership and permissions for '$DEST_FOLDER'..."
chown -R ubuntu_huawei:ubuntu_huawei "$DEST_FOLDER"
find "$DEST_FOLDER" -type d -exec chmod 755 {} +
find "$DEST_FOLDER" -type f -exec chmod 644 {} +
echo "Ownership set to ubuntu_huawei:ubuntu_huawei, directories to 755, files to 644."

################################################################################
# 4) If .gitattributes exists, parse export-ignore patterns
################################################################################
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
            # If pattern has wildcards, remove matching files & directories
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

################################################################################
# 4.5) Remove everything under vendor except 'autoload.php' and 'composer/' folder
#      Also remove 'composer.phar' if it exists in the plugin root
################################################################################
if [[ -d "$DEST_FOLDER/vendor" ]]; then
    echo "Removing everything in '$DEST_FOLDER/vendor' except autoload.php and the composer folder..."
    cd "$DEST_FOLDER/vendor"
    find . -mindepth 1 \
        ! -name 'autoload.php' \
        ! -path './composer' \
        ! -path './composer/*' \
        -exec rm -rf {} +
    cd - > /dev/null
fi

if [[ -f "$DEST_FOLDER/composer.phar" ]]; then
    echo "Removing '$DEST_FOLDER/composer.phar'..."
    rm -f "$DEST_FOLDER/composer.phar"
fi

echo "Final pre-release directory content:"
ls -R "$DEST_FOLDER"

################################################################################
# 5) Initialize Git repository if not already initialized
################################################################################
cd "$DEST_FOLDER"
if [[ ! -d ".git" ]]; then
    echo "Initializing new Git repository..."
    git init
    git remote add origin "$GITHUB_REPO"
else
    echo "Git repository already initialized."
fi

################################################################################
# 6) Create and switch to a new release branch
################################################################################
BRANCH_NAME="release-v$RELEASE_VERSION"
git checkout -b "$BRANCH_NAME" || git checkout "$BRANCH_NAME"

################################################################################
# 7) Add and commit all changes
################################################################################
echo "Committing changes..."
git add .
git commit -m "Prepare release v$RELEASE_VERSION"

################################################################################
# 8) Display final instructions about Git tagging (no automatic push)
################################################################################
echo "Release branch '$BRANCH_NAME' created locally."
echo
echo "To push this release to GitHub manually, do:"
echo "  git push -u origin $BRANCH_NAME"
echo
echo "You can then create a new release with the following tag:"
echo "  git tag -a v$RELEASE_VERSION -m 'Release version $RELEASE_VERSION'"
echo "  git push origin v$RELEASE_VERSION"

################################################################################
# 9) Create plugin ZIP for distribution (exclude .git) one level above
################################################################################
cd ..
ZIP_NAME="kymvex-inv-alert.zip"
echo "Zipping '$PLUGIN_INSTANCE' into '$ZIP_NAME', excluding any .git folders..."
zip -r "$ZIP_NAME" "$PLUGIN_INSTANCE" -x "*.git*" -x "*.git"

echo "Created ZIP file at: $(pwd)/$ZIP_NAME"

################################################################################
# 10) Copy the ZIP to the Windows Desktop folder (if using WSL)
################################################################################
if [[ ! -d "$WINDOWS_RELEASE_FOLDER" ]]; then
    echo "Creating $WINDOWS_RELEASE_FOLDER..."
    mkdir -p "$WINDOWS_RELEASE_FOLDER"
fi

echo "Copying ZIP to Windows Desktop folder..."
cp -f "$ZIP_NAME" "$WINDOWS_RELEASE_FOLDER"

echo "Copied $ZIP_NAME to $WINDOWS_RELEASE_FOLDER"
echo "Script completed successfully!"
