FROM phpswoole/swoole:php8.2

ENV TZ=Asia/Taipei
ENV COMPOSER_ALLOW_SUPERUSER=1
ARG DEBIAN_FRONTEND=noninteractive

RUN set -ex && \
    # install dependencies
    apt-get -y update && apt-get install -qq git curl autoconf pkg-config libmpdec-dev procps vim iputils-ping tmux htop unzip cron && \
    # clear out the local repository of retrieved package files
    apt-get remove -y --purge software-properties-common && \
    apt-get -y autoremove && \
    apt-get clean && \
    # install composer
    curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer && \
    composer self-update 2.5.5 && \
    # install decimal extension
    cd /tmp && \
    curl -LO https://github.com/php-decimal/ext-decimal/archive/1.x-php8.zip && unzip ./1.x-php8.zip && \
    cd /tmp/ext-decimal-1.x-php8 && \
    phpize && \
    ./configure && \
    make && make install && \
    echo "extension=decimal.so" > /usr/local/etc/php/conf.d/00_decimal.ini && \
    # override php.ini
    echo "memory_limit=1G" > /usr/local/etc/php/conf.d/00_default.ini && \
    echo "swoole.use_shortname = 'Off'" >> /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini && \
    # clean tmp files
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
