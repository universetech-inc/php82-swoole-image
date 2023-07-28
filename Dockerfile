FROM phpswoole/swoole:5.0.3-php8.2

ENV TZ=Asia/Taipei
ENV COMPOSER_ALLOW_SUPERUSER=1
ARG DEBIAN_FRONTEND=noninteractive

# Install PHP and composer dependencies
RUN apt-get -y update && apt-get install -qq git curl autoconf pkg-config libmpdec-dev procps vim iputils-ping tmux htop unzip

RUN curl -LO https://releases.hashicorp.com/vault/1.13.0/vault_1.13.0_linux_amd64.zip

RUN unzip vault_1.13.0_linux_amd64.zip

RUN mv vault /usr/local/bin/

# CRON POD 需要的
RUN apt-get install -qq cron

# Clear out the local repository of retrieved package files
RUN apt-get remove -y --purge software-properties-common \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install composer
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --version=2.5.8 --filename=composer

# install decimal
RUN set -ex \
    # download decimal extension
    && cd /tmp \
    && curl -LO https://github.com/php-decimal/ext-decimal/archive/1.x-php8.zip && unzip ./1.x-php8.zip \
    && cd /tmp/ext-decimal-1.x-php8 \
    # install decimal extension
    && phpize \
    && ./configure \
    && make \
    && make install \
    && echo "extension=decimal.so" > /usr/local/etc/php/conf.d/00_decimal.ini \
    && cd /\
    # remmove tmp dir
    && rm -rf /tmp/*
    # override php.ini
    && echo "memory_limit=1G" > /usr/local/etc/php/conf.d/00_default.ini \
    && echo "swoole.use_shortname = 'Off'" >> /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini
