#!/bin/bash

# Define variables
PLUGINS_DIR=~/wordpress-docker/common/plugins
BACKUP_DIR=$PLUGINS_DIR/woocommerce-backup
LATEST_ZIP_URL="https://downloads.wordpress.org/plugin/woocommerce.latest-stable.zip"
LATEST_ZIP_FILE=$PLUGINS_DIR/woocommerce.latest-stable.zip

# Step 1: Backup the current WooCommerce folder
echo "Backing up current WooCommerce plugin..."
if [ -d "$PLUGINS_DIR/woocommerce" ]; then
    rm -rf $BACKUP_DIR
    cp -r $PLUGINS_DIR/woocommerce $BACKUP_DIR
    echo "Backup created at $BACKUP_DIR"
else
    echo "WooCommerce directory not found. Skipping backup."
fi

# Step 2: Download the latest version of WooCommerce
echo "Downloading the latest WooCommerce plugin..."
wget -O $LATEST_ZIP_FILE $LATEST_ZIP_URL
if [ $? -ne 0 ]; then
    echo "Failed to download WooCommerce. Exiting."
    exit 1
fi

# Step 3: Unzip the downloaded file and replace the current WooCommerce plugin
echo "Unzipping the WooCommerce update..."
unzip -o $LATEST_ZIP_FILE -d $PLUGINS_DIR
if [ $? -ne 0 ]; then
    echo "Failed to unzip WooCommerce. Exiting."
    exit 1
fi

# Step 4: Remove the downloaded zip file
rm -f $LATEST_ZIP_FILE
echo "Cleaned up downloaded file."

# Step 5: Provide a success message and next steps
echo "WooCommerce has been updated successfully."
echo "Please log in to your WordPress admin panel and check for database updates under WooCommerce > Status > Tools."

exit 0
