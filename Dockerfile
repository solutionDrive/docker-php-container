ARG PHP_VERSION
ARG PHP_SHORT_VERSION
ARG XDEBUG_VERSION

FROM php:$PHP_VERSION-fpm-alpine

# Make it usable after FROM
ARG PHP_SHORT_VERSION


RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        build-base \
        libtool \
    && apk add --no-cache --virtual .persistent-deps \
        freetype-dev \
        icu-dev \
        libjpeg-turbo \
        libjpeg-turbo-dev \
        libpng \
        libpng-dev \
        libxml2 \
        libxml2-dev \
        libxml2-utils \
        libzip-dev \
    && apk add --no-cache \
        bash \
        ed \
        git \
        gzip \
        mysql-client \
        unzip \
        wget

RUN docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure calendar --enable-calendar \
    && docker-php-ext-configure gd \
        --enable-gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-configure xml --enable-xml \
    && docker-php-ext-configure zip --enable-zip --with-libzip \
    && docker-php-ext-install \
        bcmath \
        calendar \
        exif \
        fileinfo \
        gd \
        intl \
        json \
        mbstring \
        mysqli \
        pcntl \
        pdo_mysql \
        posix \
        shmop \
        soap \
        xml \
        zip \
    && pecl install redis xdebug-$XDEBUG_VERSION \
    && docker-php-ext-enable opcache redis

RUN apk del .build-deps \
    && rm -rf /tmp/*

ENTRYPOINT ['entrypoint.sh']

CMD ['php', '-a']
