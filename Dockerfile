FROM php:8.2-apache

# Gerekli PHP eklentilerini yükle
RUN docker-php-ext-install pdo pdo_mysql

# Composer yükle
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Proje dosyalarını kopyala
COPY . /var/www/html

# Apache için mod_rewrite etkinleştir
RUN a2enmod rewrite

# Gerekirse izinleri ayarla
RUN chown -R www-data:www-data /var/www/html

# Varsayılan port
EXPOSE 80
