#!/bin/bash

set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <instance-name>"
  exit 1
fi

INSTANCE_NAME=$1
INSTANCE_DIR="instances/$INSTANCE_NAME"
PLUGIN_DIR="$INSTANCE_DIR/plugin"
DB_DIR="$INSTANCE_DIR/database"

# Path to the docker-compose template file
DOCKER_COMPOSE_TEMPLATE="docker-compose.template.yml"

# Check if the docker-compose template exists
if [ ! -f "$DOCKER_COMPOSE_TEMPLATE" ]; then
  echo "Template file '$DOCKER_COMPOSE_TEMPLATE' does not exist. Exiting."
  exit 1
fi

# Create directory structure
mkdir -p "$PLUGIN_DIR"
mkdir -p "$DB_DIR"

# Copy docker-compose template
cp "$DOCKER_COMPOSE_TEMPLATE" "$INSTANCE_DIR/docker-compose.yml"

# Escape special characters in INSTANCE_NAME for sed
ESCAPED_INSTANCE_NAME=$(printf '%s\n' "$INSTANCE_NAME" | sed 's/[&/\]/\\&/g')

# Replace placeholder with actual instance name in docker-compose.yml
sed -i "s/{instance-name}/$ESCAPED_INSTANCE_NAME/g" "$INSTANCE_DIR/docker-compose.yml"

# Format the YAML file to ensure alignment and consistency using yq (if installed)
if command -v yq &> /dev/null; then
  yq eval -P "$INSTANCE_DIR/docker-compose.yml" -o=yaml -i
  echo "docker-compose.yml formatted successfully."
else
  echo "yq not found. docker-compose.yml created without additional formatting."
fi

echo "Instance '$INSTANCE_NAME' created successfully. Now you can clone your plugin repository into $PLUGIN_DIR."
