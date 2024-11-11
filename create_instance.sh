#!/bin/bash

set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <instance-name> <domain-name>"
  exit 1
fi

INSTANCE_NAME=$1
DOMAIN_NAME=$2
INSTANCE_DIR="instances/$INSTANCE_NAME"
PLUGIN_DIR="$INSTANCE_DIR/plugin"
NGINX_DIR="$INSTANCE_DIR/nginx"
CONF_D_DIR="$NGINX_DIR/conf.d"

# Path to the docker-compose template file
DOCKER_COMPOSE_TEMPLATE="docker-compose.template.yml"

# Check if the docker-compose template exists
if [ ! -f "$DOCKER_COMPOSE_TEMPLATE" ]; then
  echo "Template file '$DOCKER_COMPOSE_TEMPLATE' does not exist. Exiting."
  exit 1
fi

# Create directory structure
mkdir -p "$PLUGIN_DIR"
mkdir -p "$INSTANCE_DIR/database"
mkdir -p "$CONF_D_DIR"

# Copy docker-compose template
cp "$DOCKER_COMPOSE_TEMPLATE" "$INSTANCE_DIR/docker-compose.yml"

# Copy Nginx template files
cp nginx/nginx.conf "$NGINX_DIR/nginx.conf"
cp nginx/conf.d/default.conf "$CONF_D_DIR/default.conf"

# Replace placeholders with actual instance and domain names
ESCAPED_INSTANCE_NAME=$(printf '%s\n' "$INSTANCE_NAME" | sed 's/[&/\]/\\&/g')
ESCAPED_DOMAIN_NAME=$(printf '%s\n' "$DOMAIN_NAME" | sed 's/[&/\]/\\&/g')

# Replace placeholders in docker-compose.yml
sed -i "s/\${INSTANCE_NAME}/$ESCAPED_INSTANCE_NAME/g" "$INSTANCE_DIR/docker-compose.yml"

# Replace placeholders in Nginx configuration files
sed -i "s/\${DOMAIN_NAME}/$ESCAPED_DOMAIN_NAME/g" "$NGINX_DIR/nginx.conf"
sed -i "s/\${DOMAIN_NAME}/$ESCAPED_DOMAIN_NAME/g" "$CONF_D_DIR/default.conf"
sed -i "s/\${INSTANCE_NAME}/$ESCAPED_INSTANCE_NAME/g" "$CONF_D_DIR/default.conf"

# Format the YAML file to ensure alignment and consistency using yq (if installed)
if command -v yq &> /dev/null; then
  yq eval -P "$INSTANCE_DIR/docker-compose.yml" -o=yaml -i
  echo "docker-compose.yml formatted successfully."
else
  echo "yq not found. docker-compose.yml created without additional formatting."
fi

echo "Instance '$INSTANCE_NAME' created successfully with domain '$DOMAIN_NAME'."
echo "You can clone your plugin repository into $PLUGIN_DIR."
