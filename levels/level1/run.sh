#!/bin/sh
PORT="${1:-12221}"
CURR_PASS="${2:-escapepod}"
NEXT_PASS=$(cat /flags/level1 2>/dev/null || echo "placeholder")

docker rm -f level1 2>/dev/null || true

docker run -d \
  --name level1 \
  --restart unless-stopped \
  -p "${PORT}:22" \
  -e "LEVEL_PASSWORD=${CURR_PASS}" \
  -e "NEXT_PASS=${NEXT_PASS}" \
  escapepod/level1
