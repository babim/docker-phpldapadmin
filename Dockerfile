FROM babim/debianbase

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates \
        nginx \
        php5-fpm \
        phpldapadmin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www /etc/nginx/site*/ && ln -sf /usr/share/phpldapadmin /var/www

RUN mv /var/www/config/config.php.example /var/www/config/config.php && \
    rm -f /etc/nginx/conf.d/default.conf && rm -f /etc/php5/fpm/pool.d/www.conf

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/bootstrap.sh"]
# Define default command.
CMD ["nginx", "-g", "daemon off;"]

# Expose ports.
EXPOSE 80 443
