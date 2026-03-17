#!/bin/sh
echo "root:${LEVEL_PASSWORD:-escapepod}" | chpasswd

# Inject the real next-level password into config.php
if [ -n "${NEXT_PASS}" ]; then
  sed -i "s/LEVEL2_PASSWORD_PLACEHOLDER/${NEXT_PASS}/" /var/www/html/config.php
fi

php-fpm82 -D
nginx -g "daemon off;" &
/usr/sbin/sshd -D
