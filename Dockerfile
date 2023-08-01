FROM php:8.2.5-cli

ENV TZ=Asia/Taipei
ENV COMPOSER_ALLOW_SUPERUSER=1
ARG DEBIAN_FRONTEND=noninteractive

RUN \
    set -ex && \
    curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer && \
    composer self-update 2.5.5 && \
    apt update -y && apt install -qq git curl autoconf pkg-config libmpdec-dev procps vim iputils-ping tmux htop unzip cron libcurl4-openssl-dev libssl-dev && \
    apt remove -y --purge software-properties-common && \
    apt -y autoremove && \
    apt-get clean && \
# PHP extension pdo_mysql is included since 4.8.12+ and 5.0.1+.
    docker-php-ext-install pdo_mysql && \
    pecl channel-update pecl.php.net && \
    pecl install --configureoptions 'enable-redis-igbinary="no" enable-redis-lzf="no" enable-redis-zstd="no"' redis-5.3.7 && \
# PHP extension Redis is included since 4.8.12+ and 5.0.1+.
    docker-php-ext-enable redis && \
# Install swoole extension
    cd /tmp && pecl download swoole && \
    tar -zxvf swoole-5* && cd swoole-5* && \
    phpize && \
    ./configure --enable-openssl --enable-http2 --enable-async-redis --enable-swoole-curl && \
    make && make install && docker-php-ext-enable swoole && \
# Install decimal extension
    cd /tmp && \
    curl -LO https://github.com/php-decimal/ext-decimal/archive/1.x-php8.zip && unzip ./1.x-php8.zip && \
    cd /tmp/ext-decimal-1.x-php8 && \
    phpize && \
    ./configure && \
    make && make install && \
    echo "extension=decimal.so" > /usr/local/etc/php/conf.d/00_decimal.ini && \
# Override php.ini
    echo "memory_limit=1G" > /usr/local/etc/php/conf.d/00_default.ini && \
    echo "swoole.use_shortname = 'Off'" >> /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini && \
# Install hashicorp vault
    cd /tmp && \
    curl -LO https://releases.hashicorp.com/vault/1.13.0/vault_1.13.0_linux_amd64.zip && \
    unzip vault_1.13.0_linux_amd64.zip && rm vault_1.13.0_linux_amd64.zip && \
    mv vault /usr/local/bin && \
# Clean tmp files
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
