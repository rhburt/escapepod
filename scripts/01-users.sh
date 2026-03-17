#!/bin/sh
set -e

echo "==> Creating escapepod users and flags"

mkdir -p /flags
chmod 755 /flags

> /tmp/escapepod-passwords
for i in $(seq 1 5); do
  USER="level${i}"
  UID_VAL=$((1000 + i))

  adduser -D -u "$UID_VAL" -h "/home/${USER}" -s /bin/sh "$USER" 2>/dev/null || true

  if [ "$i" -eq 1 ]; then
    PASSWORD="escapepod"
  else
    PASSWORD=$(openssl rand -hex 12)
  fi

  echo "${USER}:${PASSWORD}" >> /tmp/escapepod-passwords
  echo "${USER}:${PASSWORD}" | chpasswd

  chmod 700 "/home/${USER}"
  chown "${USER}:${USER}" "/home/${USER}"

  BASE=$((100000 + (i - 1) * 65536))
  echo "${USER}:${BASE}:65536" >> /etc/subuid
  echo "${USER}:${BASE}:65536" >> /etc/subgid

  echo "  Created ${USER} (uid=${UID_VAL})"
done

# Plant flags: /flags/levelN owned by levelN, contains levelN+1 SSH password
for i in $(seq 1 4); do
  NEXT_PASS=$(grep "^level$((i+1)):" /tmp/escapepod-passwords | cut -d: -f2)
  CURR_UID=$((1000 + i))
  FLAGFILE="/flags/level${i}"
  echo "$NEXT_PASS" > "$FLAGFILE"
  chmod 400 "$FLAGFILE"
  chown "${CURR_UID}:${CURR_UID}" "$FLAGFILE"
  echo "  Flag level${i} planted (owned by uid ${CURR_UID})"
done

echo "CONGRATULATIONS_YOU_ESCAPED_ALL_5_CONTAINERS" > /flags/level5
chmod 400 /flags/level5
chown 1005:1005 /flags/level5

rm -f /tmp/escapepod-passwords
echo "==> Users and flags done"
