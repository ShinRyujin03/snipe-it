FROM php:8.2-apache

# Enable apache modules
RUN a2enmod rewrite

# System deps + PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl zip mariadb-client \
    libpng-dev libonig-dev libxml2-dev libzip-dev \
 && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PHP config
COPY docker/php.ini /usr/local/etc/php/conf.d/99-custom.ini

# Apache docroot
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

WORKDIR /var/www/html
