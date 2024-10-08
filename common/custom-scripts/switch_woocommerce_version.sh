#!/bin/bash

# Script to switch WooCommerce versions by downloading the plugin ZIP file

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set the path to your common plugins directory
# Adjust this path according to your directory structure
PLUGINS_DIR="$SCRIPT_DIR/../plugins"

# Set the destination path for the WooCommerce plugin
WOOCOMMERCE_PLUGIN_PATH="$PLUGINS_DIR/woocommerce"

# Function to download and extract WooCommerce plugin
download_woocommerce() {
    local version=$1
    local destination=$2

    # Construct the download URL
    DOWNLOAD_URL="https://downloads.wordpress.org/plugin/woocommerce.${version}.zip"

    # Check if the file exists on the server
    echo "Checking if WooCommerce version $version exists..."
    if ! wget --spider "$DOWNLOAD_URL" 2>/dev/null; then
        echo "Error: WooCommerce version $version does not exist."
        exit 1
    fi

    # Download the ZIP file
    echo "Downloading WooCommerce version $version..."
    wget -q -O "woocommerce.zip" "$DOWNLOAD_URL"

    if [ ! -f "woocommerce.zip" ]; then
        echo "Error: Failed to download WooCommerce version $version."
        exit 1
    fi

    # Remove existing WooCommerce plugin directory if it exists
    if [ -d "$destination" ]; then
        echo "Removing existing WooCommerce plugin at $destination..."
        rm -rf "$destination"
    fi

    # Extract the ZIP file into the plugins directory
    echo "Extracting WooCommerce version $version..."
    unzip -q "woocommerce.zip" -d "$PLUGINS_DIR"

    # Remove the ZIP file
    rm "woocommerce.zip"

    echo "WooCommerce version $version has been installed at $destination."
}

# Main script logic

# Ensure the PLUGINS_DIR exists
if [ ! -d "$PLUGINS_DIR" ]; then
    echo "Creating plugins directory at $PLUGINS_DIR..."
    mkdir -p "$PLUGINS_DIR"
fi

# Check for required commands
if ! command -v wget &> /dev/null; then
    echo "Error: wget is not installed. Please install wget to proceed."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "Error: unzip is not installed. Please install unzip to proceed."
    exit 1
fi

# Ask user for the desired WooCommerce version
read -rp "Enter the WooCommerce version (e.g., 9.3.1): " version

# Download and extract the WooCommerce plugin
download_woocommerce "$version" "$WOOCOMMERCE_PLUGIN_PATH"

# Instructions to update Docker containers (if necessary)
echo "Please ensure that your Docker containers are mounting the WooCommerce plugin from the following path:"
echo "$WOOCOMMERCE_PLUGIN_PATH"
echo "You may need to update your docker-compose.yml and restart your Docker containers for the changes to take effect."
