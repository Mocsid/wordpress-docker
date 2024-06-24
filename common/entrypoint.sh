#!/bin/bash
set -e

# Check if wp-config.php exists
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "Creating wp-config.php"
  cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

  # Update wp-config.php with database settings
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
fi

# Set the permissions for wp-config.php
chown www-data:www-data /var/www/html/wp-config.php
chmod 644 /var/www/html/wp-config.php

# Execute the original entrypoint script from WordPress image
docker-entrypoint.sh "$@"
