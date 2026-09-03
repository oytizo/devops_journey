FROM php:8.3.0-fpm-alpine

ADD ./php/www.conf /usr/local/etc/php-fpm.d/www.conf

# 1. Fixed case sensitivity: Created user and group with lowercase 'laravel'
RUN addgroup -g 1000 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

# Install required packages for Composer
RUN apk add --no-cache curl git unzip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install pdo pdo_mysql \
    && apk --no-cache add libzip-dev zlib-dev libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install zip gd

RUN apk --no-cache add --virtual .build-deps $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# 2. Fixed case sensitivity: Match the lowercase 'laravel' ownership
RUN chown -R laravel:laravel /var/www/html

# 3. Switched user context to lowercase 'laravel'
USER laravel