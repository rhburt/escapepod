#!/bin/sh
set -e

echo "==> Building level images using root daemon"

LEVELS_DIR="/opt/escapepod/levels"
ROOTLESSKIT=$(which rootlesskit)

# Build all images with root daemon
for i in $(seq 1 5); do
  LEVEL="level${i}"
  DIR="${LEVELS_DIR}/${LEVEL}"
  if [ -f "${DIR}/Dockerfile" ]; then
    echo "  Building ${LEVEL}..."
    docker build -t "escapepod/${LEVEL}" "${DIR}"
    if [ "$i" -lt 5 ]; then
      docker save "escapepod/${LEVEL}" -o "${DIR}/${LEVEL}.tar"
      chmod 644 "${DIR}/${LEVEL}.tar"
    fi
  fi
  echo "  ${LEVEL} built"
done

rc-service docker stop 2>/dev/null || true
pkill containerd 2>/dev/null || true
sleep 2

# Write per-user start scripts for levels 1-4
for i in $(seq 1 4); do
  USER="level${i}"
  UID_VAL=$((1000 + i))
  PORT=$((12220 + i))
  LEVEL="level${i}"
  DIR="${LEVELS_DIR}/${LEVEL}"
  SOCK="/run/user/${UID_VAL}/docker.sock"

  cat > "/home/${USER}/start.sh" << SCRIPT
#!/bin/sh
export XDG_RUNTIME_DIR=/run/user/${UID_VAL}
export DOCKER_HOST=unix://${SOCK}
export HOME=/home/${USER}
rm -rf /home/${USER}/.docker
${ROOTLESSKIT} --net=slirp4netns --port-driver=builtin --copy-up=/etc --copy-up=/run --disable-host-loopback -- dockerd --storage-driver=fuse-overlayfs --data-root=/home/${USER}/.docker --host=unix://${SOCK} --exec-root=/run/user/${UID_VAL}/docker --userland-proxy=true > /home/${USER}/.dockerd.log 2>&1 &
until [ -S "${SOCK}" ]; do sleep 1; done
sleep 2
docker load -i ${DIR}/${LEVEL}.tar
sh ${DIR}/run.sh \$1 \$2
SCRIPT

  chmod +x "/home/${USER}/start.sh"
  chown "${USER}:${USER}" "/home/${USER}/start.sh"
done

cat > /etc/local.d/escapepod-levels.start << 'BOOTSCRIPT'
#!/bin/sh

mkdir -p /run/docker/plugins /run/containerd /run/containerd/s
chmod 755 /run/docker /run/docker/plugins /run/containerd
chmod 777 /run/containerd/s
sysctl -w net.ipv4.ip_unprivileged_port_start=0

mkdir -p /opt/escapepod/scripts
chmod 777 /opt/escapepod/scripts

for i in $(seq 1 4); do
  rm -f /run/user/$((1000+i))/docker.sock
  rm -rf /home/level${i}/.docker
  mkdir -p /run/user/$((1000+i))
  chown level${i}:level${i} /run/user/$((1000+i))
  chmod 700 /run/user/$((1000+i))
done

for i in $(seq 1 4); do
  PORT=$((12220 + i))
  if [ "$i" -eq 1 ]; then
    CURR_PASS="escapepod"
  else
    FLAGFILE="/flags/level$((i-1))"
    CURR_PASS=$(cat "$FLAGFILE" 2>/dev/null || echo "placeholder")
  fi
  su -l level${i} -s /bin/sh -c "/home/level${i}/start.sh $PORT $CURR_PASS" &
done

# Watchdog loop for level3
nohup su -l level3 -s /bin/sh -c "while true; do sh /opt/escapepod/scripts/watchdog.sh; sleep 30; done" >> /home/level3/watchdog-loop.log 2>&1 &

# Start root daemon for level5 (CAP_SYS_MODULE requires real root)
rc-service docker start 2>/dev/null || dockerd --iptables=false > /var/log/dockerd-root.log 2>&1 &
for j in $(seq 1 30); do
  DOCKER_HOST=unix:///var/run/docker.sock docker info >/dev/null 2>&1 && break
  sleep 1
done

CURR_PASS_L5=$(cat /flags/level4 2>/dev/null || echo "placeholder")
DOCKER_HOST=unix:///var/run/docker.sock docker rm -f level5 2>/dev/null || true
DOCKER_HOST=unix:///var/run/docker.sock docker run -d \
  --name level5 --restart unless-stopped \
  --cap-add=SYS_MODULE --security-opt seccomp=unconfined \
  -v /lib/modules:/lib/modules:ro \
  -p 12225:22 -e "LEVEL_PASSWORD=${CURR_PASS_L5}" escapepod/level5

wait
BOOTSCRIPT

chmod +x /etc/local.d/escapepod-levels.start
rc-update add local default 2>/dev/null || true

echo "==> Build complete."
