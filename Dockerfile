ARG PHP_BASE=latest
FROM ghcr.io/erseco/alpine-php-webserver:${PHP_BASE}

# The base image must ship nginx 1.30.7+, which fixes the HTTP/2 RCEs
# CVE-2026-123007 and CVE-2026-123633. Fails the build on a stale base.
ARG NGINX_MIN_VERSION=1.30.7
RUN v="$(nginx -v 2>&1 | sed 's|.*/||')" \
 && [ "$(apk version -t "$v" "$NGINX_MIN_VERSION")" != "<" ] \
 || { echo "nginx $v is older than $NGINX_MIN_VERSION" >&2; exit 1; }

LABEL maintainer="Ernesto Serrano <info@ernesto.es>"

USER root
COPY --chown=nobody rootfs/ /

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

USER nobody

# Here we assume that WORDPRESS_VERSION is passed at build time. By default, we use 'latest'.
ARG WORDPRESS_VERSION=latest

ENV WP_LANGUAGE=en_US \
    DB_HOST=mariadb \
    DB_PORT=3306 \
    DB_NAME=wordpress \
    DB_USER=wordpress \
    DB_PASSWORD=wordpress \
    DB_PREFIX=wp_ \
    WP_ADMIN_EMAIL=admin@example.com \
    WP_ADMIN_USERNAME=admin \
    WP_ADMIN_PASSWORD=PLEASE_CHANGEME \
    WP_DEBUG=false \
    WP_CLI_CACHE_DIR=/tmp/wp-cli/cache/ \
    WP_THEME= \
    WP_PLUGINS= \
    WP_SITE_TITLE="WordPress Site" \
    WP_SITE_DESCRIPTION="Just another WordPress site" \
    WP_SITE_URL=http://localhost:8080 \
    client_max_body_size=50M \
    post_max_size=50M \
    upload_max_filesize=50M \
    max_input_vars=5000 \
    zlib_output_compression=Off

# Use WP-CLI to download WordPress, using the version specified or 'latest' by default.
RUN php -d memory_limit=-1 /usr/local/bin/wp core download --version=${WORDPRESS_VERSION} --path=/var/www/html
