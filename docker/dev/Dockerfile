FROM php:8.2-apache

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    # Basic tools
    curl \
    git \
    unzip \
    zip \
    vim \
    wget \
    cron \
    supervisor \
    # Image processing
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libavif-dev \
    # Database clients
    mariadb-client \
    # Other libs
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    # Node.js and npm for frontend assets
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    gd \
    mbstring \
    mysqli \
    opcache \
    pdo_mysql \
    soap \
    xml \
    zip

# Install PECL extensions
RUN pecl install redis xdebug \
    && docker-php-ext-enable redis xdebug

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure Apache
RUN a2enmod rewrite headers expires ssl
COPY docker/dev/000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy custom PHP configuration
COPY docker/dev/php.ini /usr/local/etc/php/php.ini

# Copy supervisor configuration for queue workers
COPY docker/dev/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Create storage link
RUN php artisan storage:link

# Expose ports
EXPOSE 80 443

# Create entrypoint script
COPY docker/dev/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Generate self-signed SSL certificates for development
RUN mkdir -p /etc/ssl/private /etc/ssl/certs \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=US/ST=Development/L=Local/O=Laravel Docker/OU=Development/CN=localhost"

# Start services
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 