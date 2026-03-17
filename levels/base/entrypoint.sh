#!/bin/sh
# Set the root password for SSH login
# Password is passed via environment variable at container start
ROOT_PASS="${LEVEL_PASSWORD:-level1}"
echo "root:${ROOT_PASS}" | chpasswd

# Start SSH daemon
/usr/sbin/sshd -D
