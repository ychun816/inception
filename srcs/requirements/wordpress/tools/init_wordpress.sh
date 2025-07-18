#!/bin/sh

# Exit on any error
set -e  

echo "Starting WordPress setup..."

# WordPress configuration variables (these come from environment variables)
WP_URL=${WP_URL:-"https://localhost"}
WP_TITLE=${WP_TITLE:-"My WordPress Site"}
WP_ADMIN_USER=${WP_ADMIN_USER:-"admin"}
WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-"admin123"}
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-"admin@example.com"}

# Database configuration (these come from environment variables)
DB_NAME=${MYSQL_DATABASE:-"wordpress"}
DB_USER=${MYSQL_USER:-"wpuser"}
DB_PASSWORD=${MYSQL_PASSWORD:-"wppassword"}
DB_HOST=${MYSQL_HOSTNAME:-"mariadb"}

# WordPress directory
WP_DIR="/var/www/html"

# Change to WordPress directory
cd $WP_DIR

# Check if WordPress is already downloaded
if [ ! -f wp-load.php ]; then
    echo "WordPress not found. Downloading WordPress..."
    
    # Download WordPress core files
    wp core download --allow-root --force
    
    echo "WordPress downloaded successfully."
fi

# Wait for database to be ready using mysql command (not wp db check)
echo "Waiting for database to be ready..."
until mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do
    echo "Database not ready, waiting 5 seconds..."
    sleep 5
done

echo "Database is ready."

# Create wp-config.php if it doesn't exist
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    
    # Create wp-config.php with database settings
    wp config create \
        --dbname=$DB_NAME \
        --dbuser=$DB_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=$DB_HOST \
        --allow-root
    
    echo "wp-config.php created successfully."
fi

# Now test database connection using wp-config.php
echo "Testing database connection..."
if ! wp db check --allow-root; then
    echo "Database connection failed!"
    exit 1
fi

# Install WordPress if not already installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    
    wp core install \
        --url=$WP_URL \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root
    
    echo "WordPress installed successfully."
    
    # Create additional user if specified
    if [ ! -z "$WP_USER" ] && [ ! -z "$WP_USER_PASSWORD" ] && [ ! -z "$WP_USER_EMAIL" ]; then
        echo "Creating additional user: $WP_USER"
        wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASSWORD --role=author --allow-root
        echo "User $WP_USER created successfully."
    fi
    
else
    echo "WordPress is already installed."
fi

# Set proper ownership and permissions
echo "Setting file permissions..."
chown -R www-data:www-data $WP_DIR
find $WP_DIR -type d -exec chmod 755 {} \;
find $WP_DIR -type f -exec chmod 644 {} \;

echo "WordPress setup completed successfully!"

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F
