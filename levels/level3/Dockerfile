FROM alpine:3.19
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories
RUN apk add --no-cache openssh bash python3 coreutils findutils grep util-linux

RUN ssh-keygen -A && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN mkdir -p /app /data/exports

COPY exporter.py /app/exporter.py
COPY motd /etc/motd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /app/exporter.py

COPY hint /hint
COPY solution /solution
ENTRYPOINT ["/entrypoint.sh"]
