#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME=$(basename "$0")

# Helper Function: Display Usage
usage() {
    echo "Usage: $SCRIPT_NAME <plugin_instance>"
    echo "Example: $SCRIPT_NAME kymvex-inv-alert"
    exit 1
}

# Validate Input
if [[ $# -ne 1 ]]; then
    echo "Error: Exactly one argument is required."
    usage
fi

PLUGIN_INSTANCE="$1"
COMMON_PLUGINS_FOLDER="$HOME/wordpress-docker/common/pre-release-plugin"
SOURCE_FOLDER="$HOME/wordpress-docker/instances/${PLUGIN_INSTANCE}/plugin/${PLUGIN_INSTANCE}"
DYNAMIC_MOUNTS_SCRIPT="$HOME/wordpress-docker/common/custom-scripts/generate-dynamic-mounts.sh"

# Check for required commands
if ! command -v unzip &>/dev/null; then
    echo "Error: 'unzip' command not found. Please install it before running this script."
    exit 1
fi

# Check if the source folder exists
if [[ ! -d "$SOURCE_FOLDER" ]]; then
    echo "Error: Plugin instance folder not found at $SOURCE_FOLDER"
    exit 1
fi

# Navigate to the source folder
cd "$SOURCE_FOLDER" || { echo "Error: Failed to navigate to $SOURCE_FOLDER"; exit 1; }

# Fetch Version from main plugin file
PLUGIN_FILE="${PLUGIN_INSTANCE}.php"
if [[ ! -f "$PLUGIN_FILE" ]]; then
    echo "Error: Plugin file $PLUGIN_FILE not found in $SOURCE_FOLDER"
    exit 1
fi

# Extract version line
PLUGIN_VERSION_LINE=$(grep -E "^\s*\*\s*Version:\s*" "$PLUGIN_FILE" || true)
if [[ -z "$PLUGIN_VERSION_LINE" ]]; then
    echo "Error: No 'Version:' line found in $PLUGIN_FILE"
    exit 1
fi

# Parse version from the version line
PLUGIN_VERSION=$(echo "$PLUGIN_VERSION_LINE" | awk '{print $NF}')
if [[ -z "$PLUGIN_VERSION" ]]; then
    echo "Error: Failed to determine plugin version from $PLUGIN_FILE"
    exit 1
fi

# Validate plugin version format
if ! [[ "$PLUGIN_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)*$ ]]; then
    echo "Warning: Plugin version '$PLUGIN_VERSION' doesn't follow a typical semantic version pattern."
fi

# Set Release Folder Name (without version number)
RELEASE_FOLDER="${PLUGIN_INSTANCE}"

# Full Destination Path
DEST_FOLDER="$COMMON_PLUGINS_FOLDER/$RELEASE_FOLDER"

# Remove any unnecessary files in pre-release folder
echo "Cleaning up pre-release plugin folder..."
find "$COMMON_PLUGINS_FOLDER" -type d -name "${PLUGIN_INSTANCE}-release*" -exec rm -rf {} +
find "$COMMON_PLUGINS_FOLDER" -type d -name "*$'\r'" -exec rm -rf {} +

# Remove existing folder if it exists
if [[ -d "$DEST_FOLDER" ]]; then
    echo "Removing existing folder: $DEST_FOLDER"
    rm -rf "$DEST_FOLDER"
fi

# Create the destination folder
mkdir -p "$DEST_FOLDER"

# Check if the plugin ZIP exists
PLUGIN_ZIP="${PLUGIN_INSTANCE}.zip"
if [[ ! -f "$PLUGIN_ZIP" ]]; then
    echo "Error: Plugin ZIP file $PLUGIN_ZIP not found in $SOURCE_FOLDER"
    exit 1
fi

# Extract the ZIP file into the release folder
echo "Extracting $PLUGIN_ZIP to $DEST_FOLDER..."
unzip -q "$PLUGIN_ZIP" -d "$DEST_FOLDER"

echo "Pre-release version created successfully:"
echo "- Plugin Instance: $PLUGIN_INSTANCE"
echo "- Version: $PLUGIN_VERSION"
echo "- Destination: $DEST_FOLDER"
echo "You can now activate the plugin in WordPress for testing."

# Trigger the dynamic mount script
if [[ -f "$DYNAMIC_MOUNTS_SCRIPT" ]]; then
    echo "Running dynamic mount script to update Docker mounts..."
    bash "$DYNAMIC_MOUNTS_SCRIPT" "$PLUGIN_INSTANCE"
else
    echo "Warning: Dynamic mount script $DYNAMIC_MOUNTS_SCRIPT not found in the custom-scripts folder. Please ensure it exists and rerun if needed."
fi
