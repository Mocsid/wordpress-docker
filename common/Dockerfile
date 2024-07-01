FROM wordpress:latest

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy custom entry script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entry script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the custom entry script
ENTRYPOINT ["entrypoint.sh"]

# Use the default command from the WordPress image
CMD ["apache2-foreground"]
