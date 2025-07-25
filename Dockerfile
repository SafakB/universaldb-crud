FROM php:apache

RUN apt-get update; \
    apt-get install -y libpq5 libpq-dev; \
    docker-php-ext-install pdo pdo_pgsql pdo_mysql; \
    apt-get autoremove --purge -y libpq-dev; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*    

RUN a2enmod rewrite

COPY composer.json composer.lock /var/www/html/
WORKDIR /var/www/html
RUN composer install --no-interaction --no-dev --optimize-autoloader
COPY src/ /var/www/html/