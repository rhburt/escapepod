#!/bin/sh
set -e

echo "==> Installing Docker"

apk add --no-cache \
  docker \
  docker-cli \
  docker-cli-compose \
  fuse-overlayfs \
  shadow-uidmap \
  slirp4netns \
  rootlesskit

openrc_add() {
  command -v rc-update >/dev/null 2>&1 && rc-update add "$@" || true
}
openrc_service() {
  command -v rc-service >/dev/null 2>&1 && rc-service "$@" || true
}

echo "net.ipv4.ip_unprivileged_port_start=0" >> /etc/sysctl.conf

mkdir -p /run/docker/plugins /run/containerd /run/containerd/s
chmod 755 /run/docker /run/docker/plugins /run/containerd
chmod 777 /run/containerd/s

openrc_add docker default
openrc_service docker start || dockerd --iptables=false >/tmp/dockerd.log 2>&1 &

echo "  Waiting for root Docker daemon..."
for i in $(seq 1 5); do
  docker info >/dev/null 2>&1 && break
  sleep 1
done
docker info >/dev/null 2>&1 || { echo "Root Docker daemon failed to start"; exit 1; }

for i in $(seq 1 5); do
  UID_VAL=$((1000 + i))
  mkdir -p "/run/user/${UID_VAL}"
  chown "level${i}:level${i}" "/run/user/${UID_VAL}"
  chmod 700 "/run/user/${UID_VAL}"
done

echo "==> Docker setup done"
