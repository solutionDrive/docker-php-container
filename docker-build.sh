#!/usr/bin/env bash

set -e

docker build \
    --build-arg PHP_VERSION=$PHP_VERSION \
    --build-arg PHP_SHORT_VERSION=$PHP_SHORT_VERSION \
    --build-arg XDEBUG_VERSION=$XDEBUG_VERSION \
    -t solutiondrive/docker-php-container:php$PHP_VERSION \
    .

# Tag "latest"
if [ "$LATEST" = "1" ]; then
    docker tag \
        solutiondrive/docker-php-container:php$PHP_VERSION \
        solutiondrive/docker-php-container:latest
fi
