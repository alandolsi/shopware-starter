# Wir starten mit dem offiziellen PHP 8.3 FPM Image
FROM php:8.3-fpm

# 1. System-Abhängigkeiten und Nginx/Supervisor installieren
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libxslt1-dev \
    git \
    unzip \
    mariadb-client \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Locale für UTF-8 konfigurieren
RUN sed -i '/de_DE.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=de_DE.UTF-8
ENV LC_ALL=de_DE.UTF-8

# 2. PHP Extensions konfigurieren und installieren
# Shopware benötigt: gd, zip, intl, pdo_mysql, opcache, sodium, xml, etc.
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip intl pdo_mysql opcache soap xsl bcmath sockets exif

# 2.1 Node.js installieren (für Asset-Build)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# 3. Nginx Konfiguration
RUN rm /etc/nginx/sites-enabled/default
COPY docker-nginx.conf /etc/nginx/sites-available/shopware
RUN ln -s /etc/nginx/sites-available/shopware /etc/nginx/sites-enabled/shopware

# 4. Supervisor Konfiguration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 5. PHP Konfiguration für Production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY <<EOF $PHP_INI_DIR/conf.d/shopware.ini
memory_limit = 512M
max_execution_time = 300
upload_max_filesize = 20M
post_max_size = 20M
allow_url_fopen = On
EOF

# 6. Composer installieren
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 7. Projekt-Dateien kopieren
WORKDIR /var/www/html
COPY --chown=www-data:www-data . .

# 8. Abhängigkeiten installieren (Production Mode)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 9. Assets bauen (Admin & Storefront)
# Wir setzen CI=true und PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true für schnelleren Build
ENV CI=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN npm clean-install --prefix vendor/shopware/administration/Resources/app/administration \
    && bin/build-administration.sh \
    && bin/build-storefront.sh

# 10. Verzeichnisse und Rechte
RUN mkdir -p var/cache var/log public/media public/thumbnail public/theme \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 var public/media public/thumbnail public/theme

# Marker für Environment
ENV IS_DOCKER_ENV=true

EXPOSE 80

CMD ["/usr/bin/supervisord"]
