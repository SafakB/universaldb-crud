FROM php:8.2-apache

# Gerekli sistem ve PHP bağımlılıklarını yükle
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libonig-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring

# Composer'ı yükle
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Apache doküman kökünü ayarla
ENV APACHE_DOCUMENT_ROOT=/var/www/html/src

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Proje dosyalarını kopyala
COPY . /var/www/html/

# Bağımlılıkları yükle
WORKDIR /var/www/html
RUN composer install --no-dev --optimize-autoloader

# Apache rewrite modu aç
RUN a2enmod rewrite

EXPOSE 80
CMD ["apache2-foreground"]