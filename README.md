# EscapePod

```
┌─────────────────────────────────────────┐
│                                         │
│   ███████╗███████╗ ██████╗              │
│   ██╔════╝██╔════╝██╔════╝             │
│   █████╗  ███████╗██║                  │
│   ██╔══╝  ╚════██║██║                  │
│   ███████╗███████║╚██████╗             │
│   ╚══════╝╚══════╝ ╚═════╝             │
│                                         │
│   ██████╗  ██████╗ ██████╗             │
│   ██╔══██╗██╔═══██╗██╔══██╗            │
│   ██████╔╝██║   ██║██║  ██║            │
│   ██╔═══╝ ██║   ██║██║  ██║            │
│   ██║     ╚██████╔╝██████╔╝            │
│   ╚═╝      ╚═════╝ ╚═════╝             │
│                                         │
│   escape the container. find the flag.  │
│                                         │
└─────────────────────────────────────────┘
```

A wargame challenge for Docker container escaping.

---

## The Premise

Each level SSHs you into a deliberately misconfigured Docker container. Your job is to escape it and read the flag on the host or find the flag within the container. The flag is the SSH password to the next level.

---

## Levels

<details>
<summary>Show techniques (spoilers)</summary>

| # | Technique | Difficulty |
|---|-----------|------------|
| 01 | Hardcoded credentials in PHP app | Beginner |
| 02 | Docker socket exposed | Beginner |
| 03 | Writable host-mounted script | Beginner–Intermediate |
| 04 | Shared PID namespace + `/proc` environment leak | Intermediate |
| 05 | `CAP_SYS_MODULE` + malicious kernel module | Expert |

</details>

---

## Quick Start

### Requirements

- QEMU
- 2GB RAM available for the VM
- Ports 2221–2230 free on localhost

### Install QEMU

```sh
sudo pacman -S qemu-full       # Arch
sudo apt install qemu-system   # Debian/Ubuntu
brew install qemu              # macOS
```

### Boot the VM

```sh
qemu-system-x86_64 \
  -m 2048 \
  -smp 2 \
  -drive file=output/escapepod.qcow2,format=qcow2 \
  -net user,hostfwd=tcp::2200-:22,hostfwd=tcp::2221-:12221,hostfwd=tcp::2222-:12222,hostfwd=tcp::2223-:12223,\
  -net nic \
  -enable-kvm \
  -nographic
```

Remove `-enable-kvm` on macOS or if KVM is unavailable. To exit QEMU: `Ctrl+A` then `X`.

### Connect to Level 01

```sh
ssh -p 2221 root@localhost
# Password: escapepod
```

### Level Ports

| Level | Host Port |
|-------|-----------|
| 01 | 2221 |
| 02 | 2222 |
| 03 | 2223 |
| 04 | 2224 |
| 05 | 2225 |
| 04 | 2224 |
| 05 | 2225 |

---

## How It Works

### Security Model

Each level runs under its own unprivileged user (`level1` through `level10`, UIDs 1001–1010) with its own rootless Docker daemon. Container UID 0 (root) maps to the corresponding host user via `subuid`/`subgid`. When you escape a container, you land as `levelN` on the VM host instead of root.

Flags live at `/flags/levelN` on the host. Each flag is owned by the user you become after a successful escape, with `chmod 400`. Reading it gives you the SSH password to the next level.

```
SSH into level1 container as root
    ↓
Escape the container
    ↓
Land as level1 (UID 1001) on VM host
    ↓
Read /flags/level1  (owned by level1, chmod 400)
    ↓
SSH into level2 using that password
```

### VM Architecture

```
Alpine Linux VM
│
├── /flags/
│   ├── level1   (owned by level2, contains level2 SSH password)
│   ├── level2   (owned by level3, contains level3 SSH password)
│   └── ...
│
├── level1 user (UID 1001)
│   ├── rootless dockerd  (/run/user/1001/docker.sock)
│   └── level1 container  (host:2221 → VM:12221 → container:22)
│
├── level2 user (UID 1002)
│   ├── rootless dockerd  (/run/user/1002/docker.sock)
│   └── level2 container  (host:2222 → VM:12222 → container:22)
│
└── ... levels 3 & 4 follow the same pattern
│
├── level2 user (UID 1002)
│   ├── root dockerd  (/var/run/docker.sock)
│   └── level5 container  (host:2225 → VM:12225 → container:22)
```

### Port Forwarding

QEMU's slirp network and rootlesskit both use slirp4netns internally, which conflicts if they bind the same port numbers. Containers listen on ports 12221–12230 inside the VM, and QEMU maps those to host ports 2221–2230:

```
Your machine:2221  →  VM:12221  →  container:22
```

## Building from Source

### Requirements

- [Packer](https://developer.hashicorp.com/packer/install) ≥ 1.9
- QEMU with KVM support

### Steps

**1. Get the correct ISO checksum**

```sh
wget https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.1-x86_64.iso.sha256
cat alpine-virt-3.19.1-x86_64.iso.sha256
```

Update `iso_checksum` in `escapepod.pkr.hcl`:

```hcl
variable "iso_checksum" {
  default = "sha256:<paste-checksum-here>"
}
```

**2. Build**

```sh
cd escapepod
packer init escapepod.pkr.hcl
packer build escapepod.pkr.hcl
```

Output: `output/escapepod.qcow2`

Build time is approximately 5-10 minutes, most of which is Docker image builds inside the VM.

---

## Project Structure

```
escapepod/
├── escapepod.pkr.hcl       # Packer build definition
├── http/
│   └── answers             # Alpine unattended install answers file
├── scripts/
│   ├── 00-base.sh          # Install base packages, enable community repo
│   ├── 01-users.sh         # Create level users, generate passwords, plant flags
│   ├── 02-docker.sh        # Install Docker, rootlesskit, slirp4netns, fuse-overlayfs
│   ├── 03-levels.sh        # Create level directory structure
│   ├── 04-hardening.sh     # Lock down SSH, home dirs, /proc hidepid
│   ├── 05-build-levels.sh  # Build Docker images, write per-user start scripts
│   └── escapepod.initd     # OpenRC service for boot startup
└── levels/
    ├── base/               # Base Dockerfile shared by all levels
    └── level1–level10/
        ├── Dockerfile      # Challenge container definition
        ├── entrypoint.sh   # Sets SSH password from env var, starts sshd
        ├── run.sh          # Reads flag, starts container with correct password
        └── motd            # The one nudge players get
```

### Adding a New Level

1. Create `levels/levelNN/` with `Dockerfile`, `entrypoint.sh`, `run.sh`, and `motd`
2. Update the loop bounds in `01-users.sh`, `02-docker.sh`, and `05-build-levels.sh` from `seq 1 5` to `seq 1 NN`
3. Rebuild with Packer

---

## Acknowledgements

Inspired by [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) and [Kubernetes Goat](https://madhuakula.com/kubernetes-goat/). Container escape techniques documented by [Trail of Bits](https://blog.trailofbits.com/), [NCC Group](https://research.nccgroup.com/), and the broader container security community.
