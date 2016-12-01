#!/bin/bash
set -e

LDAP_SERVER_HOST="${LDAP_SERVER_HOST:-openldap}"
LDAP_SERVER_PORT="${LDAP_SERVER_PORT:-389}"
USER="${USER:-www-data}"
GROUP"${GROUP:-www-data}"
UNIQUE_ATTRS="${UNIQUE_ATTRS:-mail,uid,uidNumber}"
TIMEZONE=$(cat /etc/timezone)

if [ ! -f "/etc/php5/fpm/pool.d/www.conf" ]; then
cat <<EOF>> /etc/php5/fpm/pool.d/www.conf
[global]
daemonize = no

[www]
user = $USER
group = $GROUP

listen = /var/run/php5-fpm.sock

listen.owner = $USER
listen.group = $GROUP
listen.mode = 0660

pm = dynamic

pm.max_children = 10
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 4
pm.max_requests = 500

php_admin_value[date.timezone] = $TIMEZONE

php_admin_value[upload_max_filesize] = 100M
php_admin_value[post_max_size] = 100M

;php_admin_value[output_buffering] = 0
EOF

if [ ! -f "/etc/nginx/conf.d/default.conf" ]; then
cat <<'EOF'>> /etc/nginx/conf.d/default.conf
server {
    listen 80;

    root /var/www;

    client_max_body_size 100M;
    fastcgi_buffers 64 4K;

    index index.php;
  
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ~ ^/(?:\.htaccess|config|temp|logs) {
        deny all;
    }

    location / {
        try_files $uri $uri/ /index.php;
    }

    location ~ [^/]\.php(?:$|/) {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;

        if (!-f $document_root$fastcgi_script_name) {
            return 404;
        }

        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;

        fastcgi_pass unix:/var/run/php5-fpm.sock;
    }
}
EOF

sed -i "s/^\/\/ \(\$servers->setValue('server','host','\).*\(');\)$/\1$LDAP_SERVER_HOST\2/g" /var/www/config/config.php
sed -i "s/^\/\/ \(\$servers->setValue('server','port',\).*\();\)$/\1$LDAP_SERVER_PORT\2/g" /var/www/config/config.php

attr_string=""

IFS=","; declare -a attrs=($UNIQUE_ATTRS)

for attr in "${attrs[@]}"; do
    attr_string="$attr_string,'$attr'"
done

attr_string="${attr_string:1}"

sed -i "s/^#  \(\$servers->setValue('unique','attrs',\).*\();\)$/\1array($attr_string)\2/g" /var/www/config/config.php

if [ "$1" = '/run.sh' ]; then
	exec /run.sh "$@"
fi

# run PHP-fpm
php5-fpm -D

exec "$@"
