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

# Create directory structure
mkdir -p $PLUGIN_DIR
mkdir -p $DB_DIR

# Copy docker-compose template
cp docker-compose-template.yml $INSTANCE_DIR/docker-compose.yml

# Replace placeholder with actual instance name
sed -i "s/{instance-name}/$INSTANCE_NAME/g" $INSTANCE_DIR/docker-compose.yml

echo "Instance $INSTANCE_NAME created successfully. Now you can clone your plugin repository into $PLUGIN_DIR"
