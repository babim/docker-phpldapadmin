FROM babim/debianbase

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates \
        nginx \
        php5-fpm \
        phpldapadmin && \
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
