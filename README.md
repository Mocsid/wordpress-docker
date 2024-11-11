
# WordPress Docker Environment for Plugin Testing

This repository sets up a Docker environment to test different WordPress plugins with persistent database storage. The setup includes a common folder for shared files and individual instance folders for each plugin.

## Directory Structure

```
wordpress-docker/
├── common/
│   ├── .env
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── init.sql
│   ├── wordpress/
│   └── plugins/
│       ├── woocommerce
│       └── MOC-WP-Logger-1.0.0
├── instances/
│   ├── <instance-name>/
│   │   ├── docker-compose.yml
│   │   ├── database/
│   │   └── plugin/
│   │       └── <your-plugin-name>/
└── README.md
```

## Setup Instructions

### Step 1: Common Directory Setup

1. **Create Initialization Script**

   Create the `init.sql` file in the `common` directory:

   ```sh
   nano ~/wordpress-docker/common/init.sql
   ```

   Add the following content:

   ```sql
   CREATE DATABASE IF NOT EXISTS exampledb;
   CREATE USER 'exampleuser'@'%' IDENTIFIED BY 'examplepass';
   GRANT ALL PRIVILEGES ON exampledb.* TO 'exampleuser'@'%';
   FLUSH PRIVILEGES;
   ```

2. **Verify Dockerfile and Entrypoint Script**

   Ensure you have a `Dockerfile` and `entrypoint.sh` in your `common` directory.

   **Dockerfile**:

   ```dockerfile
   FROM wordpress:latest

   # Copy custom entry script
   COPY entrypoint.sh /usr/local/bin/entrypoint.sh

   # Make the entry script executable
   RUN chmod +x /usr/local/bin/entrypoint.sh

   # Use the custom entry script
   ENTRYPOINT ["entrypoint.sh"]

   # Use the default command from the WordPress image
   CMD ["apache2-foreground"]
   ```

   **Entrypoint Script (`entrypoint.sh`)**:

   ```sh
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
   ```

### Step 2: Instance Directory Setup

1. **Create `docker-compose.yml` for the Plugin Instance**

   Edit the `docker-compose.yml` file for the plugin instance:

   ```sh
   nano ~/wordpress-docker/instances/<instance-name>/docker-compose.yml
   ```

   Add the following content:

   ```yaml
   version: '3.1'

   services:
     wordpress:
       build: ../../common
       restart: always
       ports:
         - "8081:80"
       env_file:
         - ../../common/.env
       volumes:
         - ../../common/wordpress:/var/www/html
         - ../../common/plugins/woocommerce:/var/www/html/wp-content/plugins/woocommerce
         - ../../common/plugins/MOC-WP-Logger-1.0.0:/var/www/html/wp-content/plugins/MOC-WP-Logger-1.0.0
         - ./plugin/<your-plugin-name>:/var/www/html/wp-content/plugins/<your-plugin-name>
       deploy:
         resources:
           limits:
             cpus: "1.0"
             memory: "512M"

     db:
       image: mysql:5.7
       restart: always
       env_file:
         - ../../common/.env
       environment:
         MYSQL_ROOT_PASSWORD: somerootpassword
       volumes:
         - db_data:/var/lib/mysql
         - ../../common/init.sql:/docker-entrypoint-initdb.d/init.sql
       deploy:
         resources:
           limits:
             cpus: "0.5"
             memory: "256M"

   volumes:
     db_data:
   ```

### Step 3: Build and Run the Containers

1. **Navigate to the instance directory and run the build process**:

   ```sh
   cd ~/wordpress-docker/instances/<instance-name>
   docker-compose down
   docker-compose up --build -d
   ```

### Step 4: Verify Setup

1. **Access the WordPress site**:

   Open your web browser and navigate to `http://localhost:8081`. You should see the WordPress installation page if everything is set up correctly.

2. **Log in to the WordPress admin panel and verify the plugins**:

   Navigate to the Plugins page to ensure that WooCommerce, MOC-WP-Logger-1.0.0, and your specific plugin are active.

### Step 5: Test Database Persistence

1. **Create some changes in the WordPress site** (e.g., create a post, change settings).

2. **Stop and remove the containers**:

   ```sh
   docker-compose down
   ```

3. **Start the containers again**:

   ```sh
   docker-compose up -d
   ```

4. **Verify that the changes are still present** by accessing the WordPress site and checking the changes you made earlier.
