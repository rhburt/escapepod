FROM alpine:3.19
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories
RUN apk add --no-cache openssh bash docker-cli curl util-linux coreutils procps findutils grep

RUN ssh-keygen -A && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN mkdir -p /etc/backup-agent /var/log/backup-agent

COPY config.yml /etc/backup-agent/config.yml
COPY agent.log /var/log/backup-agent/agent.log
COPY motd /etc/motd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY hint /hint
COPY solution /solution
ENTRYPOINT ["/entrypoint.sh"]
