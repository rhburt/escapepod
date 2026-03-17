#!/bin/sh
# Automated Alpine install script
# Served by Packer's HTTP server, fetched during boot

# Set root password so Packer can SSH in after reboot
echo 'root:packer' | chpasswd

# Configure SSH to allow root login during provisioning
cat > /etc/ssh/sshd_config << 'EOF'
PermitRootLogin yes
PasswordAuthentication yes
EOF

# Alpine setup: use answers file for non-interactive install
cat > /tmp/answers << 'EOF'
KEYMAPOPTS="us us"
HOSTNAMEOPTS="-n escapepod"
INTERFACEOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp"
DNSOPTS="-d local -n 1.1.1.1"
TIMEZONEOPTS="-z UTC"
PROXYOPTS="none"
APKREPOSOPTS="-1"
SSHDOPTS="-c openssh"
NTPOPTS="-c none"
DISKOPTS="-m sys /dev/vda"
LBUOPTS="none"
APKCACHEOPTS="none"
EOF

# Run setup (will format /dev/vda and install)
setup-alpine -ef /tmp/answers

# Copy sshd config to installed system
cp /etc/ssh/sshd_config /mnt/etc/ssh/sshd_config
