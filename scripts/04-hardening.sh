#!/bin/sh
set -e

echo "==> Hardening the host"

# Restrict SSH: players can only SSH into containers (via port 2221-2230)
# Direct host SSH is only for admin/setup
cat > /etc/ssh/sshd_config << 'EOF'
# Wargame host SSH - restricted
Port 22
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
AllowUsers root

# Only allow root for maintenance (disable after setup if desired)
Match User root
  PermitRootLogin yes
EOF

# Players cannot SSH directly into the host as levelX users
# They must go through the containers
# Add AllowUsers to restrict direct host SSH to root only
# (levelX users SSH into containers on ports 2221-2230, not the host)

# Prevent level users from reading each other's home directories
for i in $(seq 1 5); do
  USER="level${i}"
  chmod 700 "/home/${USER}"
  chown "${USER}:${USER}" "/home/${USER}"
done

# /etc/passwd is readable by all (normal), but shadow is not
chmod 640 /etc/shadow
chown root:shadow /etc/shadow

# Install escapepod OpenRC service
cp /opt/escapepod/levels/../escapepod.initd /etc/init.d/escapepod 2>/dev/null || true
# (escapepod.initd is copied via Packer file provisioner to /opt/escapepod/)
chmod +x /etc/init.d/escapepod 2>/dev/null || true
rc-update add escapepod default 2>/dev/null || true

# Write MOTD shown when players enter a level container
cat > /etc/escapepod-motd << 'EOF'

  ██████╗ ██████╗ ███╗   ██╗████████╗ █████╗ ██╗███╗   ██╗███████╗██████╗
 ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝██╔══██╗
 ██║     ██║   ██║██╔██╗ ██║   ██║   ███████║██║██╔██╗ ██║█████╗  ██████╔╝
 ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██║██║██║╚██╗██║██╔══╝  ██╔══██╗
 ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║██║ ╚████║███████╗██║  ██║
  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
  ███████╗███████╗ ██████╗ █████╗ ██████╗ ███████╗███████╗
  ██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
  █████╗  ███████╗██║     ███████║██████╔╝█████╗  ███████╗
  ██╔══╝  ╚════██║██║     ██╔══██║██╔═══╝ ██╔══╝  ╚════██║
  ███████╗███████║╚██████╗██║  ██║██║     ███████╗███████║
  ╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝

  You are inside a container. Escape it.
  The password to the next level is in /home/$(whoami)/.next_password on the host.

EOF

# Ensure /run/docker exists for Docker daemon
mkdir -p /run/docker/plugins
chmod 755 /run/docker /run/docker/plugins

echo "==> Hardening done"
