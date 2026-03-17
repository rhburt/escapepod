FROM alpine:3.19
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories
RUN apk add --no-cache openssh bash procps coreutils findutils grep util-linux

RUN ssh-keygen -A && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN mkdir -p /app /var/metrics

COPY collector.sh /app/collector.sh
COPY motd /etc/motd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /app/collector.sh

COPY hint /hint
COPY solution /solution
ENTRYPOINT ["/entrypoint.sh"]
