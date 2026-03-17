FROM alpine:3.19
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories
RUN apk add --no-cache openssh bash php82 php82-fpm nginx coreutils procps grep findutils

RUN ssh-keygen -A && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN mkdir -p /var/www/html /run/nginx /run/php

COPY index.php /var/www/html/index.php
COPY config.php /var/www/html/config.php
COPY nginx.conf /etc/nginx/nginx.conf
COPY motd /etc/motd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY hint /hint
COPY solution /solution
ENTRYPOINT ["/entrypoint.sh"]
