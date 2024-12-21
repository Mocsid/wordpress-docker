#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME=$(basename "$0")

usage() {
    echo "Usage: $SCRIPT_NAME <plugin_instance>"
    exit 1
}

if [[ $# -ne 1 ]]; then
    echo "Error: Exactly one argument is required."
    usage
fi

PLUGIN_INSTANCE="$1"

# Paths
PRE_RELEASE_DIR="$HOME/wordpress-docker/common/pre-release-plugin"
SOURCE_FOLDER="$HOME/wordpress-docker/instances/${PLUGIN_INSTANCE}/plugin/${PLUGIN_INSTANCE}"
DEST_FOLDER="$PRE_RELEASE_DIR/$PLUGIN_INSTANCE"
GITATTR_FILE="$SOURCE_FOLDER/.gitattributes"  # Adjust if your .gitattributes is located elsewhere

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
        # Skip empty lines or lines not containing 'export-ignore'
        [[ -z "$line" ]] && continue
        [[ "$line" != *"export-ignore"* ]] && continue
        
        # Extract the pattern (first column)
        pattern="$(echo "$line" | awk '{print $1}')"

        # Clean up leading/trailing slashes for easier 'find' usage
        # This is a simplistic approach; adjust as needed
        stripped_pattern="${pattern#/}"
        stripped_pattern="${stripped_pattern%/}"

        echo "Removing pattern: $pattern (interpreted as $stripped_pattern)"
        
        # If pattern has wildcards (e.g., *.log), we handle them
        # We'll do a 'find' under $DEST_FOLDER matching the pattern
        # This is tricky: .gitattributes patterns can differ from find patterns
        # We'll do a best-effort approach
        if [[ "$stripped_pattern" == *"*"* ]]; then
            # Find matching files by name
            find "$DEST_FOLDER" -type f -name "$stripped_pattern" -exec rm -f {} +
            find "$DEST_FOLDER" -type d -name "$stripped_pattern" -exec rm -rf {} +
        else
            # Remove exact path matches
            # This handles cases like /tests or /bin
            find "$DEST_FOLDER" -path "*/$stripped_pattern" -exec rm -rf {} +
        fi
    done < <(grep 'export-ignore' "$GITATTR_FILE")
else
    echo "No .gitattributes file found at $GITATTR_FILE; skipping export-ignore parsing."
fi

echo "Final pre-release directory: $DEST_FOLDER"
ls -R "$DEST_FOLDER"

# Optional: run a dynamic mount script if needed
DYNAMIC_MOUNTS_SCRIPT="$HOME/wordpress-docker/common/custom-scripts/generate-dynamic-mounts.sh"
if [[ -f "$DYNAMIC_MOUNTS_SCRIPT" ]]; then
    echo "Running dynamic mount script..."
    bash "$DYNAMIC_MOUNTS_SCRIPT" "$PLUGIN_INSTANCE"
fi

echo "Done."
