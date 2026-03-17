#!/bin/sh
echo "root:${LEVEL_PASSWORD:-level2}" | chpasswd
/usr/sbin/sshd -D
