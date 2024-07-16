#!/bin/sh
#
# WordPress configuration script
#
set -eo pipefail

# Path to WordPress root directory
wp_root="/var/www/html"

# Function to check the availability of a database
check_db_availability() {
    local db_host="$1"
    local db_port="$2"

    echo "Waiting for $db_host:$db_port to be ready..."
    while ! nc -w 1 "$db_host" "$db_port" > /dev/null 2>&1; do
        # Show some progress
        echo -n '.'
        sleep 1
    done
    echo -e "\n\nGreat, $db_host is ready!"
}

# Check the availability of the primary database
check_db_availability "$DB_HOST" "$DB_PORT"

# Execute pre-install commands if the variable is set
if [ -n "$PRE_CONFIGURE_COMMANDS" ]; then
    echo "Executing pre-configure commands..."
    eval "$PRE_CONFIGURE_COMMANDS"
fi

# Check if wp-config.php exists and create it if not
if [ ! -f "$wp_root/wp-config.php" ]; then
    wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="$DB_HOST" --dbprefix="$DB_PREFIX" --path="$wp_root"
fi

# Install WordPress if not already installed
if ! wp core is-installed --path="$wp_root"; then
    wp core install --url="$WP_SITE_URL" --title="$WP_SITE_TITLE" --admin_user="$WP_ADMIN_USERNAME" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL" --path="$wp_root"
fi

# Check if HTTPS detection snippet is already in wp-config.php, add if not
if ! grep -q "HTTP_X_FORWARDED_PROTO" "$wp_root/wp-config.php"; then
    echo "Adding HTTPS detection snippet to wp-config.php..."
    sed -i "1 a\\
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && strpos(\$_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false)\\
       \$_SERVER['HTTPS']='on';\\
" "$wp_root/wp-config.php"
fi

# Configure site settings
wp config set WP_DEBUG "$WP_DEBUG" --raw

wp option update blogname "${WP_SITE_TITLE}" --path="$wp_root"
wp option update blogdescription "${WP_SITE_DESCRIPTION}" --path="$wp_root"

# Install and activate theme if WP_THEME is specified
if [ -n "$WP_THEME" ]; then
    wp theme install "$WP_THEME" --activate --path="$wp_root"
fi

# Install and activate plugins if WP_PLUGINS is specified
if [ -n "$WP_PLUGINS" ]; then
    OLD_IFS="$IFS"
    IFS=','
    for plugin in $WP_PLUGINS; do
        wp plugin install "$plugin" --activate --path="$wp_root"
    done
    IFS="$OLD_IFS"
fi

# Configure language (if different to default en_US)
if [ "$WP_LANGUAGE" != "en_US" ]; then

    # Install the specified language package
    wp language core install "$WP_LANGUAGE"
    # Switch the site language to the specified language
    wp site switch-language "$WP_LANGUAGE"

fi

# Execute post-install commands if the variable is set
if [ -n "$POST_CONFIGURE_COMMANDS" ]; then
    echo "Executing post-configure commands..."
    eval "$POST_CONFIGURE_COMMANDS"
fi

echo "WordPress has been successfully configured."