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
    NGINX_DIR="${INSTANCE_DIR%/}/nginx"
    CONF_D_DIR="$NGINX_DIR/conf.d"
    
    echo "Processing instance: $INSTANCE_NAME"

    # Copy the template to the instance directory
    cp "$DOCKER_COMPOSE_TEMPLATE" "$DOCKER_COMPOSE_FILE"

    # Copy Nginx template files
    cp nginx/nginx.conf "$NGINX_DIR/nginx.conf"
    cp nginx/conf.d/default.conf "$CONF_D_DIR/default.conf"

    # Read the domain name from a configuration file or set a default
    if [ -f "${INSTANCE_DIR%/}/domain.conf" ]; then
      DOMAIN_NAME=$(cat "${INSTANCE_DIR%/}/domain.conf")
    else
      DOMAIN_NAME="example.com"
    fi

    # Escape special characters in INSTANCE_NAME and DOMAIN_NAME for sed
    ESCAPED_INSTANCE_NAME=$(printf '%s\n' "$INSTANCE_NAME" | sed 's/[&/\]/\\&/g')
    ESCAPED_DOMAIN_NAME=$(printf '%s\n' "$DOMAIN_NAME" | sed 's/[&/\]/\\&/g')

    # Replace placeholders in docker-compose.yml
    sed -i "s/\${INSTANCE_NAME}/$ESCAPED_INSTANCE_NAME/g" "$DOCKER_COMPOSE_FILE"

    # Replace placeholders in Nginx configuration files
    sed -i "s/\${DOMAIN_NAME}/$ESCAPED_DOMAIN_NAME/g" "$NGINX_DIR/nginx.conf"
    sed -i "s/\${DOMAIN_NAME}/$ESCAPED_DOMAIN_NAME/g" "$CONF_D_DIR/default.conf"
    sed -i "s/\${INSTANCE_NAME}/$ESCAPED_INSTANCE_NAME/g" "$CONF_D_DIR/default.conf"

    # Format the YAML file to ensure alignment and consistency
    yq eval -P "$DOCKER_COMPOSE_FILE" -o=yaml -i

    echo "docker-compose.yml and Nginx configuration updated and formatted for instance: $INSTANCE_NAME"
  fi
done

echo "All docker-compose.yml and Nginx configuration files have been updated and formatted successfully."
