#!/bin/sh
set -e

echo "==> Setting up level infrastructure"

mkdir -p /opt/escapepod/levels

for i in $(seq 1 3); do
  mkdir -p "/opt/escapepod/levels/level$(printf '%02d' $i)"
done

echo "==> Level infrastructure done"
