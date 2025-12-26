FROM php:8.3-apache

# Enable Apache rewrite
RUN a2enmod rewrite

# System deps + PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip curl zip mariadb-client \
    libpng-dev libonig-dev libxml2-dev libzip-dev \
 && docker-php-ext-install \
    pdo_mysql mbstring exif pcntl bcmath gd zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PHP config (optional)
COPY docker/php.ini /usr/local/etc/php/conf.d/99-custom.ini

# App directory
WORKDIR /var/www/html

# Copy source code
COPY . .

# Install PHP dependencies
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Apache docroot -> public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

# Permissions (Laravel)
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 80
