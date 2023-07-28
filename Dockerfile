FROM phpswoole/swoole:5.0.3-php8.2

ENV TZ=Asia/Taipei
ENV COMPOSER_ALLOW_SUPERUSER=1
ARG DEBIAN_FRONTEND=noninteractive

# install decimal
RUN set -ex \
    && cd /tmp \
    # install dependencies
    && apt-get -y update && apt-get install -qq git curl autoconf pkg-config libmpdec-dev procps vim iputils-ping tmux htop unzip cron \
    # clear out the local repository of retrieved package files
    && apt-get remove -y --purge software-properties-common \
    && apt-get -y autoremove \
    && apt-get clean \
    # download decimal extension
    && curl -LO https://github.com/php-decimal/ext-decimal/archive/1.x-php8.zip && unzip ./1.x-php8.zip \
    && cd /tmp/ext-decimal-1.x-php8 \
    # install decimal extension
    && phpize \
    && ./configure \
    && make \
    && make install \
    && echo "extension=decimal.so" > /usr/local/etc/php/conf.d/00_decimal.ini \
    # override php.ini
    && echo "memory_limit=1G" > /usr/local/etc/php/conf.d/00_default.ini \
    && echo "swoole.use_shortname = 'Off'" >> /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini \
    # install hashicorp vault
    && curl -LO https://releases.hashicorp.com/vault/1.13.0/vault_1.13.0_linux_amd64.zip \
    && unzip vault_1.13.0_linux_amd64.zip && rm vault_1.13.0_linux_amd64.zip \
    && mv vault /usr/local/bin \
    # clean tmp files
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
