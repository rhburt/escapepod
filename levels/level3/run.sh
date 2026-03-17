#!/bin/sh
PORT="${1:-12223}"
CURR_PASS="${2:-placeholder}"

docker rm -f level3 2>/dev/null || true

SCRIPTS_DIR="/opt/escapepod/scripts"
mkdir -p "$SCRIPTS_DIR"
chmod 777 "$SCRIPTS_DIR"

cat > "$SCRIPTS_DIR/watchdog.sh" << 'SCRIPT'
#!/bin/sh
LOG="/home/level3/watchdog.log"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] report-exporter: running" >> "$LOG"
SCRIPT

chown 1003:1003 "$SCRIPTS_DIR/watchdog.sh"
chmod 755 "$SCRIPTS_DIR/watchdog.sh"

docker run -d \
  --name level3 \
  --restart unless-stopped \
  -p "${PORT}:22" \
  -e "LEVEL_PASSWORD=${CURR_PASS}" \
  -v "$SCRIPTS_DIR:/host-scripts" \
  escapepod/level3
