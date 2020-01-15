ARG PHP_VERSION
ARG PHP_SHORT_VERSION
ARG XDEBUG_VERSION

FROM php:$PHP_VERSION-fpm-alpine

# Make it usable after FROM
ARG PHP_SHORT_VERSION
ARG XDEBUG_VERSION

COPY config/memory-limit.ini $PHP_INI_DIR/conf.d/

RUN set -xe
RUN apk add --no-cache \
        bash \
        coreutils \
        ed \
        freetype \
        git \
        gzip \
        icu \
        libjpeg-turbo \
        libltdl \
        libmcrypt \
        libpng \
        libxml2 \
        libzip \
        msmtp \
        mysql-client \
        unzip \
        wget
RUN apk add --no-cache --virtual .sd-build-deps \
        autoconf \
        build-base \
        libtool
RUN apk add --no-cache --virtual .sd-persistent-deps \
        freetype-dev \
        icu-dev \
        imap-dev \
        libc-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        oniguruma-dev \
        libpng-dev \
        libxml2-dev \
        libxml2-utils \
        libzip-dev \
        pcre-dev \
        pkgconf

RUN docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure calendar --enable-calendar \
    && docker-php-ext-configure iconv \
    && docker-php-ext-configure imap --with-imap \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure shmop --enable-shmop \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-configure sysvshm --enable-sysvshm \
    && docker-php-ext-configure xml --enable-xml

RUN if [ "$PHP_SHORT_VERSION" = "74" ]; then \
    docker-php-ext-configure gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
    && docker-php-ext-configure zip --with-zip; \
else \
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
    && docker-php-ext-configure zip --enable-zip --with-libzip; \
fi

RUN docker-php-ext-install \
        bcmath \
        calendar \
        exif \
        fileinfo \
        gd \
        iconv \
        imap \
        intl \
        json \
        mbstring \
        mysqli \
        pcntl \
        pdo_mysql \
        posix \
        shmop \
        soap \
        sysvshm \
        xml \
        zip

RUN pecl install redis xdebug-$XDEBUG_VERSION
RUN docker-php-ext-enable opcache redis
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail

RUN apk del .sd-build-deps \
    && rm -rf /tmp/*
