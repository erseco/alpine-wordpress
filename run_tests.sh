#!/usr/bin/env sh
apk --no-cache add curl

# Check that the database is available
echo "Waiting for WordPress to be ready"
while ! nc -w 1 app 8080; do
    # Show some progress
    echo -n '.';
    sleep 1;
done
echo "WordPress is ready"
# Give it another 3 seconds.
sleep 3;

curl --silent --fail http://app:8080 | grep '<title>WordPress Site</title>'
