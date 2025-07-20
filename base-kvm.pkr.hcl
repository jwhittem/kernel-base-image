packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variables {
  output_dir = "output"
  output_name = "kernel-base-image.qcow2"
  source_checksum_url = "file:https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/SHA256SUMS"
  source_iso  = "https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
  ssh_password = "debian"
  ssh_username = "debian"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

build {
  sources = ["source.qemu.debian"]

  provisioner "shell" {
    inline = [
      "mkdir -p /home/debian/kernel-base-image/scripts /home/debian/kernel-base-image/files"
    ]
  }

  provisioner "file" {
    source = "./scripts/"
    destination = "/home/debian/kernel-base-image/scripts/"
  }

  provisioner "file" {
    source = "./files/"
    destination = "/home/debian/kernel-base-image/files/"
  }

  provisioner "shell" {
    inline = ["sh -cx 'sudo bash /home/debian/kernel-base-image/scripts/install.sh'"]
  }
}

source qemu "debian" {
  iso_url      = "${var.source_iso}"
  iso_checksum = "${var.source_checksum_url}"

  cpus = 6
  memory      = 4096
  disk_size   = 102400
  accelerator = "kvm"

  headless = false # false if you want to see VNC install

  # Serve the `http` directory via HTTP, used for preseeding the Debian installer.
  http_directory = "http"
  http_port_min  = 9990
  http_port_max  = 9999

  # SSH ports to redirect to the VM being built
  host_port_min = 2222
  host_port_max = 2229

  # This user is configured in the preseed file.
  ssh_password     = "${var.ssh_password}"
  ssh_username     = "${var.ssh_username}"
  ssh_wait_timeout = "600s"

  shutdown_command = "echo '${var.ssh_password}'  | sudo -S /sbin/shutdown -hP now"

  # Builds a compact image
  disk_compression   = true
  disk_discard       = "unmap"
  skip_compaction    = false
  disk_detect_zeroes = "unmap"
  format           = "qcow2"
  output_directory = "${var.output_dir}"
  vm_name          = "${var.output_name}"

  boot_wait = "1s"
  boot_command = [
    "<down><tab>", # non-graphical install
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "language=en locale=en_US.UTF-8 ",
    "country=US keymap=en ",
    "hostname=debian domain=home.arpa ", # Should be overriden after DHCP, if available
    "<enter><wait>",
  ]
}
