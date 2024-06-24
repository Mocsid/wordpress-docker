FROM wordpress:latest

# Copy custom entry script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entry script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use the custom entry script
ENTRYPOINT ["entrypoint.sh"]

# Use the default command from the WordPress image
CMD ["apache2-foreground"]
