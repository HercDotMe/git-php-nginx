FROM php:8.3-fpm

ENV INDEX_FILE='index.php'
ENV DOCUMENT_ROOT='/public'
ENV GIT_REPO=''

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    locales \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    supervisor \
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mbstring exif pcntl opcache

#INSTALL APCU
RUN pecl install apcu && docker-php-ext-enable apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/php.ini
RUN echo "apc.enable_cli=1" > /usr/local/etc/php/php.ini
RUN echo "apc.enable=1" > /usr/local/etc/php/php.ini
#APCU

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy config file
COPY nginx.conf /etc/nginx/conf.d/nginx_conf_template

# Clear document root
RUN rm -rfv /var/www/*

# Copy entrypoint file
COPY entrypoint.sh /etc/nginx/entrypoint.sh
RUN ["chmod", "+x", "/etc/nginx/entrypoint.sh"]

# Copy supervisord conf
COPY ./supervisord.conf /etc/supervisord.conf

# Workdir definition
WORKDIR /var/www

# Expose port
EXPOSE 80

ENTRYPOINT ["/etc/nginx/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n"]
