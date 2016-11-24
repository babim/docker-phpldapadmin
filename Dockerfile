FROM babim/nginx.php5

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        phpldapadmin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/phpldapadmin /var/www

RUN mv /var/www/config/config.php.example /var/www/config/config.php

COPY default.conf /etc/nginx/conf.d/

COPY www.conf /etc/php5/fpm/pool.d/

COPY bootstrap.sh /

ENTRYPOINT ["/bootstrap.sh"]

# This script comes from the parent image
CMD ["/run.sh"]
