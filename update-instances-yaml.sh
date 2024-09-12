#!/bin/bash

set -e

# Directory containing all instance folders
INSTANCE_BASE_DIR="instances"

# Check if yq is installed
if ! command -v yq &> /dev/null; then
  echo "yq command not found. Please install yq to proceed."
  exit 1
fi

# Loop through each folder in the instance directory
for INSTANCE_DIR in $INSTANCE_BASE_DIR/*; do
  if [ -d "$INSTANCE_DIR" ]; then
    INSTANCE_NAME=$(basename "$INSTANCE_DIR")
    DOCKER_COMPOSE_FILE="$INSTANCE_DIR/docker-compose.yml"
    
    # Check if the docker-compose.yml exists in the instance folder
    if [ -f "$DOCKER_COMPOSE_FILE" ]; then
      echo "Updating docker-compose.yml for instance: $INSTANCE_NAME"
      
      # Replace {instance-name} with the actual folder name
      sed -i "s/{instance-name}/$INSTANCE_NAME/g" "$DOCKER_COMPOSE_FILE"
      
      # Format the YAML file to ensure alignment and consistency
      yq eval -P "$DOCKER_COMPOSE_FILE" -i

      echo "docker-compose.yml updated and formatted for instance: $INSTANCE_NAME"
    else
      echo "docker-compose.yml not found for instance: $INSTANCE_NAME. Skipping..."
    fi
  fi
done

echo "All docker-compose.yml files have been updated and formatted successfully."
