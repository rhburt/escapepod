#!/bin/sh
PORT="${1:-12225}"
CURR_PASS="${2:-placeholder}"

export DOCKER_HOST=unix:///var/run/docker.sock
docker rm -f level5 2>/dev/null || true

docker run -d \
  --name level5 \
  --restart unless-stopped \
  --cap-add=SYS_MODULE \
  --security-opt seccomp=unconfined \
  -v /lib/modules:/lib/modules:ro \
  -p "${PORT}:22" \
  -e "LEVEL_PASSWORD=${CURR_PASS}" \
  escapepod/level5
