# Base image for all escapepod levels
# Provides SSH server and minimal tooling
# Each level builds FROM this

FROM alpine:3.19
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories

RUN apk add --no-cache \
  openssh \
  bash \
  curl \
  wget \
  procps \
  util-linux \
  coreutils \
  grep \
  findutils \
  file

# Create the level user inside the container
# UID 0 = root inside = levelX user outside (via rootless Docker UID mapping)
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# MOTD
COPY motd /etc/motd

# SSH config: password auth on, root login allowed
RUN ssh-keygen -A && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
  echo "PrintMotd yes" >> /etc/ssh/sshd_config && \
  echo "Banner /etc/motd" >> /etc/ssh/sshd_config

# Entrypoint starts SSH daemon and keeps container running
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
