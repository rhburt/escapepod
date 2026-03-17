#!/bin/sh
PORT="${1:-12222}"
CURR_PASS="${2:-placeholder}"
SOCK="/run/user/$(id -u)/docker.sock"

docker rm -f level2 2>/dev/null || true

docker run -d \
  --name level2 \
  --restart unless-stopped \
  -p "${PORT}:22" \
  -e "LEVEL_PASSWORD=${CURR_PASS}" \
  -v "${SOCK}:/var/run/docker.sock" \
  escapepod/level2
