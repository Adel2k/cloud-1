FROM debian:bullseye

ENV PHP_VERSION 7.4

RUN mkdir -p /run/php

RUN	apt update -y && apt upgrade -y
RUN apt install -y default-mysql-client

RUN apt install -y \
	curl \
	wget \
	php${PHP_VERSION} \
	php${PHP_VERSION}-cgi \
	php${PHP_VERSION}-mysql \
	php${PHP_VERSION}-fpm \
	php${PHP_VERSION}-pdo \
	php${PHP_VERSION}-gd \
	php${PHP_VERSION}-cli \
	php${PHP_VERSION}-mbstring \
	php${PHP_VERSION}-redis \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY ./www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/

COPY ./wp-setup.sh /
RUN chmod +x /wp-setup.sh

EXPOSE 9000

CMD [ "/wp-setup.sh"]