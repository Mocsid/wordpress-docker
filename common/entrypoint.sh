#!/bin/bash
set -e

# Check if wp-config.php exists
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "Creating wp-config.php"
  cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

  # Update wp-config.php with database settings directly
  sed -i "s/database_name_here/exampledb/" /var/www/html/wp-config.php
  sed -i "s/username_here/exampleuser/" /var/www/html/wp-config.php
  sed -i "s/password_here/examplepass/" /var/www/html/wp-config.php
  sed -i "s/localhost/db:3306/" /var/www/html/wp-config.php
else
  echo "wp-config.php already exists, skipping creation."
fi

# Set the permissions for wp-config.php
echo "Setting permissions for wp-config.php"
chown www-data:www-data /var/www/html/wp-config.php
chmod 644 /var/www/html/wp-config.php

# Write out the cron job
if ! grep -q "/usr/local/bin/php /var/www/html/wp-cron.php" /etc/crontab; then
  echo "* * * * * www-data /usr/local/bin/php /var/www/html/wp-cron.php" >> /etc/crontab
  echo "Cron job added."
else
  echo "Cron job already exists, skipping."
fi

# Ensure that cron is running
echo "Starting cron service"
service cron start

# Execute the original entrypoint script from WordPress image
echo "Executing original WordPress entrypoint"
exec docker-entrypoint.sh "$@"
