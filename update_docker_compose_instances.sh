#!/bin/bash

set -e

# Directory containing all instance folders
INSTANCE_BASE_DIR="instances"

# Path to the docker-compose template file
DOCKER_COMPOSE_TEMPLATE="docker-compose.template.yml"

# Check if yq is installed
if ! command -v yq &> /dev/null; then
  echo "yq command not found. Please install yq to proceed."
  exit 1
fi

# Check if the instances directory exists
if [ ! -d "$INSTANCE_BASE_DIR" ]; then
  echo "Directory '$INSTANCE_BASE_DIR' does not exist. Exiting."
  exit 1
fi

# Check if the docker-compose template exists
if [ ! -f "$DOCKER_COMPOSE_TEMPLATE" ]; then
  echo "Template file '$DOCKER_COMPOSE_TEMPLATE' does not exist. Exiting."
  exit 1
fi

# Enable nullglob to handle cases where no directories are found
shopt -s nullglob

# Loop through each folder in the instance directory
for INSTANCE_DIR in "$INSTANCE_BASE_DIR"/*/; do
  if [ -d "$INSTANCE_DIR" ]; then
    INSTANCE_NAME=$(basename "$INSTANCE_DIR")
    DOCKER_COMPOSE_FILE="${INSTANCE_DIR%/}/docker-compose.yml"
    
    echo "Processing instance: $INSTANCE_NAME"

    # Copy the template to the instance directory
    cp "$DOCKER_COMPOSE_TEMPLATE" "$DOCKER_COMPOSE_FILE"
    
    # Escape special characters in INSTANCE_NAME for sed
    ESCAPED_INSTANCE_NAME=$(printf '%s\n' "$INSTANCE_NAME" | sed 's/[&/\]/\\&/g')

    # Replace {instance-name} with the actual folder name using sed
    sed -i "s/{instance-name}/$ESCAPED_INSTANCE_NAME/g" "$DOCKER_COMPOSE_FILE"

    # Format the YAML file to ensure alignment and consistency
    yq eval -P "$DOCKER_COMPOSE_FILE" -o=yaml -i

    echo "docker-compose.yml updated and formatted for instance: $INSTANCE_NAME"
  fi
done

echo "All docker-compose.yml files have been updated and formatted successfully."
