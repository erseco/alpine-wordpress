# WordPress on Alpine Linux

[![Docker Pulls](https://img.shields.io/docker/pulls/erseco/alpine-wordpress.svg)](https://hub.docker.com/r/erseco/alpine-wordpress/)
![Docker Image Size](https://img.shields.io/docker/image-size/erseco/alpine-wordpress)
![nginx 1.24.0](https://img.shields.io/badge/nginx-1.18-brightgreen.svg)
![php 8.2](https://img.shields.io/badge/php-8.2-brightgreen.svg)
![WordPress-6.4.3](https://img.shields.io/badge/wordpress-yellow)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)
<a href="https://www.buymeacoffee.com/erseco"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" height="20px"></a>

WordPress setup for Docker, build on [Alpine Linux](http://www.alpinelinux.org/).
The image is only +/- 70MB large.

Repository: https://github.com/erseco/alpine-wordpress


* Built on the lightweight image https://github.com/erseco/alpine-php-webserver
* Very small Docker image size (+/-70MB)
* Uses PHP 8.2 for better performance, lower cpu usage & memory footprint
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

## Configuration
Define the ENV variables in docker-compose.yml file

| Variable Name        | Default                 | Description                                      |
|----------------------|-------------------------|--------------------------------------------------|
| WP_LANGUAGE          | en_US                   | WordPress site language                          |
| DB_HOST              | mariadb                 | Database host                                    |
| DB_PORT              | 3306                    | MySQL default port                               |
| DB_NAME              | wordpress               | Database name                                    |
| DB_USER              | wordpress               | Database user                                    |
| DB_PASSWORD          | wordpress               | Database password                                |
| DB_PREFIX            | wp_                     | Database prefix for WordPress tables             |
| WP_ADMIN_EMAIL       | admin@example.com       | WordPress admin email                            |
| WP_ADMIN_USERNAME    | admin                   | WordPress admin username                         |
| WP_ADMIN_PASSWORD    | PLEASE_CHANGEME         | WordPress admin password                         |
| WP_DEBUG             | false                   | Enable/disable WordPress debugging               |
| WP_CLI_CACHE_DIR     | /tmp/wp-cli/cache/      | WP-CLI cache directory path                      |
| WP_THEME             |                         | Active WordPress theme                           |
| WP_PLUGINS           |                         | Comma-separated list of WordPress plugins        |
| WP_SITE_TITLE        | WordPress Site          | Title of the WordPress site                      |
| WP_SITE_DESCRIPTION  | Just another WordPress site | Description of the WordPress site             |
| WP_SITE_URL          | http://localhost:8080   | WordPress site URL                               |
| client_max_body_size | 50M                     | Maximum allowed size of client request bodies    |
| post_max_size        | 50M                     | Maximum size of POST data that PHP will accept   |
| upload_max_filesize  | 50M                     | Maximum size of an uploaded file                 |
| max_input_vars       | 5000                    | Maximum number of input variables for PHP        |
| PRE_CONFIGURE_COMMANDS |                       | Commands to run before starting the configuration |
| POST_CONFIGURE_COMMANDS |                      | Commands to run after finished the configuration |

