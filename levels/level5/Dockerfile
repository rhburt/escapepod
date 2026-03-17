FROM alpine:3.19
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories
RUN apk add --no-cache \
  openssh bash gcc make musl-dev \
  linux-virt-dev linux-headers \
  kmod coreutils procps findutils grep

RUN ssh-keygen -A && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN mkdir -p /root/module

COPY escape.c /root/module/escape.c
COPY Makefile /root/module/Makefile
COPY motd /etc/motd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY hint /hint
COPY solution /solution
ENTRYPOINT ["/entrypoint.sh"]
