#!/bin/bash

# Default values
DEFAULT_USER="admin_pdf_watermark"
DEFAULT_PRODUCT_ID=92

# Check if a user and product ID are provided, otherwise use defaults
USER=${1:-$DEFAULT_USER}
PRODUCT_ID=${2:-$DEFAULT_PRODUCT_ID}

# Create a new order and capture the order ID
order_id=$(wp wc shop_order create --status=processing --user=$USER --allow-root --porcelain)
echo "Created order with ID: $order_id"

# Add line items to the order
wp wc shop_order update $order_id --line_items='[{"product_id": '"$PRODUCT_ID"', "quantity": 1}]' --user=$USER --allow-root
echo "Added line items to order ID: $order_id"

# Update billing details
wp wc shop_order update $order_id --billing='{"first_name":"John", "last_name":"Doe", "address_1":"1234 Elm Street", "city":"Springfield", "state":"IL", "postcode":"62701", "country":"US", "email":"test@test.com", "phone":"+1 555-123-4567"}' --user=$USER --allow-root
echo "Updated billing details for order ID: $order_id"

# Update shipping details
wp wc shop_order update $order_id --shipping='{"first_name":"John", "last_name":"Doe", "address_1":"1234 Elm Street", "city":"Springfield", "state":"IL", "postcode":"62701", "country":"US"}' --user=$USER --allow-root
echo "Updated shipping details for order ID: $order_id"

# Mark the order as completed
wp wc shop_order update $order_id --status=completed --user=$USER --allow-root
echo "Order ID $order_id has been marked as completed"
