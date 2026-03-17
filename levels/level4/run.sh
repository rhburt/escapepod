#!/bin/sh
PORT="${1:-12224}"
CURR_PASS="${2:-placeholder}"
NEXT_PASS=$(cat /flags/level4 2>/dev/null || echo "placeholder")

docker rm -f level4 level4-config 2>/dev/null || true

docker run -d \
  --name level4-config \
  -e "SERVICE=config-manager" \
  -e "NEXT_PASSWORD=${NEXT_PASS}" \
  alpine:3.19 \
  sh -c 'while true; do sleep 3600; done'

docker run -d \
  --name level4 \
  --restart unless-stopped \
  --pid=host \
  -p "${PORT}:22" \
  -e "LEVEL_PASSWORD=${CURR_PASS}" \
  escapepod/level4
