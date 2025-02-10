#!/bin/bash

set -euo pipefail

# Usage: generate-dynamic-mounts.sh <plugin_instance>
if [[ $# -ne 1 ]]; then
    echo "Error: Exactly one argument is required."
    echo "Usage: $0 <plugin_instance>"
    exit 1
fi

PLUGIN_INSTANCE="$1"
PRE_RELEASE_DIR="$HOME/wordpress-docker/common/pre-release-plugin"
TARGET_YML="$HOME/wordpress-docker/docker-compose.override.yml"

# Ensure pre-release directory exists
if [[ ! -d "$PRE_RELEASE_DIR" ]]; then
    echo "Error: Pre-release directory not found at $PRE_RELEASE_DIR."
    exit 1
fi

# Check if the plugin folder exists in pre-release directory
PLUGIN_FOLDER="$PRE_RELEASE_DIR/$PLUGIN_INSTANCE"
if [[ ! -d "$PLUGIN_FOLDER" ]]; then
    echo "Error: Plugin folder $PLUGIN_FOLDER does not exist."
    exit 1
fi

# Start the override YAML file
cat <<EOL > "$TARGET_YML"
version: "3.1"
services:
  wordpress:
    volumes:
      - $PRE_RELEASE_DIR/$PLUGIN_INSTANCE:/var/www/html/wp-content/plugins/$PLUGIN_INSTANCE
EOL

echo "Dynamic mount added for plugin: $PLUGIN_INSTANCE"
