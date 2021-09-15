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
        wget \
        grep
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
        pkgconf \
        libwebp-dev \
        postgresql-dev \
        postgresql

# Fix iconv (see comments in the linked issue)
# Previously https://github.com/docker-library/php/issues/240#issuecomment-305038173 now https://github.com/docker-library/php/issues/240#issuecomment-876464325
RUN apk add gnu-libiconv=1.15-r3 --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

RUN docker-php-ext-configure bcmath --enable-bcmath
RUN docker-php-ext-configure calendar --enable-calendar
RUN docker-php-ext-configure iconv
RUN docker-php-ext-configure imap --with-imap
RUN docker-php-ext-configure intl --enable-intl
RUN docker-php-ext-configure pcntl --enable-pcntl
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql
RUN docker-php-ext-configure pgsql --with-pgsql
RUN docker-php-ext-configure mbstring --enable-mbstring
RUN docker-php-ext-configure shmop --enable-shmop
RUN docker-php-ext-configure soap --enable-soap
RUN docker-php-ext-configure sysvshm --enable-sysvshm
RUN docker-php-ext-configure xml --enable-xml

RUN if [ $(echo " $PHP_SHORT_VERSION >= 74" | bc) -eq 1 ]; then \
    docker-php-ext-configure gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
        --with-webp=/usr/include/ \
    && docker-php-ext-configure zip --with-zip; \
else \
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-webp-dir=/usr/include/ \
    && docker-php-ext-configure zip --enable-zip --with-libzip; \
fi

RUN docker-php-ext-install bcmath
RUN docker-php-ext-install calendar
RUN docker-php-ext-install exif
RUN docker-php-ext-install fileinfo
RUN docker-php-ext-install gd
RUN docker-php-ext-install iconv
RUN docker-php-ext-install imap
RUN docker-php-ext-install intl
RUN if [ $(echo " $PHP_SHORT_VERSION <= 74" | bc) -eq 1 ]; then \
  docker-php-ext-install json; \
fi
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install posix
RUN docker-php-ext-install shmop
RUN docker-php-ext-install soap
RUN docker-php-ext-install sysvshm
RUN docker-php-ext-install xml
RUN docker-php-ext-install zip

RUN pecl install redis xdebug-$XDEBUG_VERSION
RUN docker-php-ext-enable opcache redis
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail

RUN apk del .sd-build-deps \
    && rm -rf /tmp/*
