#!/bin/sh
echo "root:${LEVEL_PASSWORD:-level3}" | chpasswd
/usr/sbin/sshd -D
