#!/bin/sh
echo "root:${LEVEL_PASSWORD:-level5}" | chpasswd
/usr/sbin/sshd -D
