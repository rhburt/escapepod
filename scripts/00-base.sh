#!/bin/sh
set -e

echo "==> Installing base packages"

# Enable community repo for shadow and other packages
sed -i 's|#.*community|http://dl-cdn.alpinelinux.org/alpine/v3.19/community|' /etc/apk/repositories

apk update
apk add --no-cache \
  bash \
  curl \
  wget \
  git \
  openssh \
  openssl \
  util-linux \
  e2fsprogs \
  coreutils \
  procps \
  grep \
  sed \
  tar \
  gzip \
  ca-certificates \
  shadow \
  gawk

echo "==> Base packages done"
