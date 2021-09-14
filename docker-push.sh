#!/usr/bin/env bash

set -e

echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
docker push solutiondrive/docker-php-container
docker push solutiondrive/php
