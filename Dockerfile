FROM babim/debianbase

ENV NGINX_VERSION 1.6.2
ENV PHP_VERSION 5.6.20
ENV PHPLDAPADMIN_VERSION 1.2.3

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        ca-certificates \
        nginx=${NGINX_VERSION}* \
        php5-fpm=${PHP_VERSION}* && \
        phpldapadmin=${PHPLDAPADMIN_VERSION}* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/phpldapadmin /var/www

RUN mv /var/www/config/config.php.example /var/www/config/config.php

COPY default.conf /etc/nginx/conf.d/

COPY www.conf /etc/php5/fpm/pool.d/

COPY bootstrap.sh /

ENTRYPOINT ["/bootstrap.sh"]
# Define default command.
CMD ["nginx", "-g", "daemon off;"]

# Expose ports.
EXPOSE 80 443
