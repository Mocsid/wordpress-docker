FROM wordpress:latest

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Install necessary dependencies, Redis server, SOAP extension, and Puppeteer dependencies
RUN apt-get update && \
    apt-get install -y libxml2-dev cron redis-server curl gnupg git ca-certificates libnss3 libxss1 libatk-bridge2.0-0 libgtk-3-0 libasound2 libdrm2 libgbm1 libxcb-dri3-0 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 xdg-utils && \
    docker-php-ext-install soap && \
    pecl install redis && \
    docker-php-ext-enable redis

# Install Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install Puppeteer globally and set up cache directory with correct permissions
RUN npm install puppeteer --unsafe-perm=true --allow-root && \
    mkdir -p /var/www/.cache && chmod -R 777 /var/www/.cache && \
    PUPPETEER_CACHE_DIR=/var/www/.cache/puppeteer
    
RUN apt-get update && apt-get install -y xvfb

# Clean up to reduce the image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Modify www-data user to have the same UID and GID as the host user (ubuntu_huawei)
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Copy custom entry script from the common directory
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entry script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the custom entry script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Use the default command from the WordPress image
CMD ["apache2-foreground"]
