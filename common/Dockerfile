FROM wordpress:latest

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Install necessary dependencies, Redis server, and the SOAP extension
RUN apt-get update && \
    apt-get install -y libxml2-dev cron redis-server && \
    docker-php-ext-install soap && \
    pecl install redis && \
    docker-php-ext-enable redis

# Clean up to reduce the image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy custom entry script from the common directory
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entry script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the custom entry script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Use the default command from the WordPress image
CMD ["apache2-foreground"]
