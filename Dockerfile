# Temel PHP görüntüsü (Apache ile)
FROM php:8.2-apache

# Gerekli PHP eklentilerini kur
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_mysql mbstring

# Composer kur
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Apache için belge kökünü ayarla
ENV APACHE_DOCUMENT_ROOT=/var/www/html/src

# Apache ayarını güncelle (public dizinin dışında çalışıyorsan)
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