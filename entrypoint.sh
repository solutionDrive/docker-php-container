#!/bin/sh

set -e
USE_XDEBUG=false

# check if the environment contains XDEBUG and it is true
if [ ! -z "$XDEBUG" ] && [ "$XDEBUG" = true ]; then
    USE_XDEBUG=true
fi

# check if we call phpx and enable xdebug if its the case
if [ "$1" = "phpx" ]; then
    USE_XDEBUG=true
    shift
    set -- php "$@"
fi

# enable xdebug
if [ "$USE_XDEBUG" = true ]; then
    echo "USING XDEBUG"
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini
fi

# execute script
exec "$@"
