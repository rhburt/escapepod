#!/bin/sh
echo "root:${LEVEL_PASSWORD:-level4}" | chpasswd
/usr/sbin/sshd -D
