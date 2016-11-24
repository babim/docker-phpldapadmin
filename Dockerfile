FROM babim/nginx.php5.alpine

RUN apk add --no-cache phpldapadmin

RUN ln -sf /usr/share/phpldapadmin /var/www

RUN mv /var/www/config/config.php.example /var/www/config/config.php

COPY default.conf /etc/nginx/conf.d/

COPY www.conf /etc/php5/fpm/pool.d/

COPY bootstrap.sh /

ENTRYPOINT ["/bootstrap.sh"]

