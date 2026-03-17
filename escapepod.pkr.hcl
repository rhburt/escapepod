packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "alpine_version" {
  default = "3.19.1"
}

variable "iso_checksum" {
  default = "sha256:366317d854d77fc5db3b2fd774f5e1e5db0a7ac210614fd39ddb555b09dbb344"
}

source "qemu" "alpine-escapepod" {
  iso_url          = "https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-${var.alpine_version}-x86_64.iso"
  iso_checksum     = var.iso_checksum
  output_directory = "output"
  vm_name          = "escapepod.qcow2"

  disk_size    = "8192"
  memory       = 2048
  cpus         = 2
  format       = "qcow2"
  accelerator  = "kvm"

  ssh_username     = "root"
  ssh_password     = "packer"
  ssh_wait_timeout = "30m"
  ssh_port         = 22

  shutdown_command = "poweroff"

  http_directory = "http"

  boot_wait = "15s"
  boot_command = [
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answers<enter><wait>",
    "setup-alpine -f answers<enter><wait5>",
    "packer<enter><wait>",
    "packer<enter><wait5>",
    "<wait>no<enter><wait8>",
    "<wait>y<enter><wait30>",
    "rc-service sshd stop<enter><wait2>",
    "mount /dev/vda3 /mnt<enter><wait5>",
    "ls /mnt/etc<enter><wait2>",

    # Modify sshd config in installed system
    "sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /mnt/etc/ssh/sshd_config<enter>",
    "echo 'PasswordAuthentication yes' >> /mnt/etc/ssh/sshd_config<enter>",

    # Install haveged into the installed system (not the live env)
    "apk add --root /mnt --no-cache haveged<enter><wait15>",
    "ln -sf /etc/init.d/haveged /mnt/etc/runlevels/default/haveged<enter>",

    "umount /mnt<enter><wait2>",
    "reboot<enter>"
  ]
}

build {
  name    = "escapepod"
  sources = ["source.qemu.alpine-escapepod"]

  provisioner "shell" {
    inline = ["echo 'SSH is up'"]
  }

  provisioner "shell" {
    execute_command = "sh '{{ .Path }}'"
    scripts = [
      "scripts/00-base.sh",
      "scripts/01-users.sh",
      "scripts/02-docker.sh",
      "scripts/03-levels.sh",
      "scripts/04-hardening.sh"
    ]
  }

  provisioner "file" {
    source      = "levels/"
    destination = "/opt/escapepod/levels"
  }

  provisioner "file" {
    source      = "scripts/escapepod.initd"
    destination = "/etc/init.d/escapepod"
  }

  provisioner "shell" {
    execute_command   = "chmod +x /etc/init.d/escapepod; sh '{{ .Path }}' > /tmp/build-levels.log 2>&1; echo $? > /tmp/build-levels.exit"
    script            = "scripts/05-build-levels.sh"
    valid_exit_codes  = [0]
  }

  # Print the full log so Packer shows it on failure
  provisioner "shell" {
    inline = ["cat /tmp/build-levels.log; exit $(cat /tmp/build-levels.exit)"]
  }
}
