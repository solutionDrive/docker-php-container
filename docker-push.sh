#!/usr/bin/env bash

set -e

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
for i in `docker images --format "{{.Repository}}:{{.Tag}}" | grep "solutiondrive"`; do docker push $i; done
