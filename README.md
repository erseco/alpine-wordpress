# WordPress on Alpine Linux

[![Docker Pulls](https://img.shields.io/docker/pulls/erseco/alpine-wordpress.svg)](https://hub.docker.com/r/erseco/alpine-wordpress/)
![Docker Image Size](https://img.shields.io/docker/image-size/erseco/alpine-wordpress)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)
<a href="https://www.buymeacoffee.com/erseco"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" height="20px"></a>

WordPress setup for Docker, build on [Alpine Linux](http://www.alpinelinux.org/).
The image is only +/- 70MB large.

Repository: https://github.com/erseco/alpine-wordpress


* Built on the lightweight image https://github.com/erseco/alpine-php-webserver
* Very small Docker image size (+/-70MB)
* Uses PHP 8.3 for better performance, lower cpu usage & memory footprint
* Multi-arch support: 386, amd64, arm/v6, arm/v7, arm64, ppc64le, s390x
* Optimized for 1000 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's ondemand PM)
* Use of runit instead of supervisord to reduce memory footprint
* docker-compose sample with MariaDB
* Configuration via ENV variables
* Easily upgradable to new WordPress versions
* Includes [WP-CLI](https://wp-cli.org/) for command-line management and automation of WordPress tasks, enhancing site management and deployment capabilities.
* The servers Nginx, PHP-FPM run under a non-privileged user (nobody) to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible with `docker logs -f <container name>`)
* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs

## Usage

Start the Docker containers:

    docker-compose up

Login on the system using the provided credentials (ENV vars)

## Running Commands as Root

In certain situations, you might need to run commands as `root` within your WordPress container, for example, to install additional packages. You can do this using the `docker-compose exec` command with the `--user root` option. Here's how:

```bash
docker-compose exec --user root wordpress sh
```

## WordPress Plugin Development Environment Setup

Below is a `docker-compose.yml` example specifically designed for WordPress plugin development. This configuration provides a comprehensive setup for developing, testing, and deploying WordPress plugins efficiently.

```yaml
services:
  mariadb:
    image: mariadb:latest
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=wordpress
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - MYSQL_PASSWORD=wordpress
    volumes:
      - mariadb:/var/lib/mysql

  wordpress:
    image: erseco/alpine-wordpress:latest
    restart: unless-stopped
    depends_on:
      - mariadb
    ports:
      - 8080:8080      
    environment:
      WP_LANGUAGE: es_ES
      WP_ADMIN_USERNAME: admin
      WP_ADMIN_PASSWORD: PLEASE_CHANGEME
      WP_DEBUG: true
      WP_PLUGINS: user-access-manager
      WP_SITE_URL: http://localhost:8080
      POST_CONFIGURE_COMMANDS: |
        echo "Creating user for testing"
        if ! wp user get test1 --field=ID --quiet; then
          wp user create test1 test1@example.com --role=subscriber --user_pass=test1
        fi
        echo "Activating plugin"
        wp plugin activate my-plugin
    volumes:
      - wordpress:/var/www/html
      - ./my-plugin:/var/www/html/wp-content/plugins/my-plugin

volumes:
  mariadb: null
  wordpress: null
```

- **MariaDB service**: Configures a MariaDB database with WordPress-specific settings, ensuring data persistence through Docker volumes.
- **WordPress service**:
  - Uses `erseco/alpine-wordpress:latest`, tailored for WordPress development.
  - Sets up WordPress with Spanish language, admin credentials, and enables debugging.
  - Pre-installs and activates specified plugins, including a custom plugin located in `./my-plugin`.
  - Executes custom commands after configuration, like creating a test user and activating the developed plugin.
  - Maps port 8080, allowing local access to the WordPress site.
  - Depends on the `mariadb` service for database connectivity.

### How to Use

1. Save the provided `docker-compose.yml` in your project directory.
2. Place your plugin code inside a directory named `my-plugin` in the same location.
3. Execute `docker-compose up -d` in your terminal, within the project directory.
4. Access your WordPress site at `http://localhost:8080` to test and develop your plugin in a real-world environment.

This setup streamlines the plugin development process, from coding and testing to deployment, within a controlled and consistent environment.

## Configuration
Define the ENV variables in docker-compose.yml file

| Variable Name           | Default                     | Description                                       |
|-------------------------|-----------------------------|---------------------------------------------------|
| WP_LANGUAGE             | en_US                       | WordPress site language                           |
| DB_HOST                 | mariadb                     | Database host                                     |
| DB_PORT                 | 3306                        | MySQL default port                                |
| DB_NAME                 | wordpress                   | Database name                                     |
| DB_USER                 | wordpress                   | Database user                                     |
| DB_PASSWORD             | wordpress                   | Database password                                 |
| DB_PREFIX               | wp_                         | Database prefix for WordPress tables              |
| WP_ADMIN_EMAIL          | admin@example.com           | WordPress admin email                             |
| WP_ADMIN_USERNAME       | admin                       | WordPress admin username                          |
| WP_ADMIN_PASSWORD       | PLEASE_CHANGEME             | WordPress admin password                          |
| WP_DEBUG                | false                       | Enable/disable WordPress debugging                |
| WP_CLI_CACHE_DIR        | /tmp/wp-cli/cache/          | WP-CLI cache directory path                       |
| WP_THEME                |                             | Active WordPress theme                            |
| WP_PLUGINS              |                             | Comma-separated list of WordPress plugins         |
| WP_SITE_TITLE           | WordPress Site              | Title of the WordPress site                       |
| WP_SITE_DESCRIPTION     | Just another WordPress site | Description of the WordPress site                 |
| WP_SITE_URL             | http://localhost:8080       | WordPress site URL                                |
| client_max_body_size    | 50M                         | Maximum allowed size of client request bodies     |
| post_max_size           | 50M                         | Maximum size of POST data that PHP will accept    |
| upload_max_filesize     | 50M                         | Maximum size of an uploaded file                  |
| max_input_vars          | 5000                        | Maximum number of input variables for PHP         |
| zlib_output_compression | Off                         | Disable zlib compresion for PHP                   |
| PRE_CONFIGURE_COMMANDS  |                             | Commands to run before starting the configuration |
| POST_CONFIGURE_COMMANDS |                             | Commands to run after finished the configuration  |

