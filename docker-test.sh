#!/usr/bin/env bash

set -e

ATTRIBUTES_TEMPLATE_FILE="tests/inspec/php-container/attributes.yml.template"
ATTRIBUTES_FILE="tests/inspec/php-container/attributes.yml"
cp ${ATTRIBUTES_TEMPLATE_FILE} ${ATTRIBUTES_FILE}
printf '%s\n' ",s~{{ php_version }}~${PHP_VERSION}~g" w q | ed -s "${ATTRIBUTES_FILE}"
printf '%s\n' ",s~{{ php_short_version }}~${PHP_SHORT_VERSION}~g" w q | ed -s "${ATTRIBUTES_FILE}"

DOCKER_CONTAINER_ID=`docker run -d solutiondrive/docker-php-container:php$PHP_VERSION`
bundle exec inspec exec tests/inspec/php-container --attrs tests/inspec/php-container/attributes.yml -t docker://${DOCKER_CONTAINER_ID}
docker stop ${DOCKER_CONTAINER_ID}
