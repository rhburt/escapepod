#!/bin/sh
# metrics-collector v2.0
# Reads process stats directly from /proc.
# Requires host PID namespace to observe all system processes.
echo "[metrics-collector] starting"
while true; do
  ls /proc | grep -c '^[0-9]' >> /var/metrics/procs.log 2>/dev/null || true
  sleep 30
done
