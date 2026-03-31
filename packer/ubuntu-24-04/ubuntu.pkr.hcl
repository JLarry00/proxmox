packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# ============================================================
# Variables — sobrescribir con: packer build -var-file=...
# o con variables de entorno PKR_VAR_*
# ============================================================

variable "proxmox_url" {
  type    = string
  default = "https://192.168.13.13:8006/api2/json"
}

variable "proxmox_username" {
  type    = string
  default = "juan.larrondo@pve!terraform"
}

variable "proxmox_token" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "proxmoxdev01"
}

variable "template_vm_id" {
  type    = number
  default = 400
}

variable "template_name" {
  type    = string
  default = "ubuntu-2404-base-image"
}

variable "template_description" {
  type    = string
  default = "Plantilla inmutable Ubuntu 24.04 — construida con Packer"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
}

variable "iso_checksum" {
  type    = string
  default = "d6dab0c3a657988501e9b2ef2a56b66a00bc22c8c87c9d82be7e466a2091b13e"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "network_bridge" {
  type    = string
  default = "vmbr1"
}

variable "packer_username" {
  type    = string
  default = "packer_user"
}

variable "packer_password_plain" {
  type      = string
  sensitive = true
}

variable "packer_password_hash" {
  type      = string
  sensitive = true
  # Generar con: openssl passwd -6 "TU_CONTRASEÑA"
}

# ============================================================
# Fuente
# ============================================================

source "proxmox-iso" "ubuntu_2404" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  insecure_skip_tls_verify = true

  node                 = var.proxmox_node
  vm_id                = var.template_vm_id
  vm_name              = var.template_name
  template_description = var.template_description

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  os                = "l26"
  cores             = var.cores
  memory            = var.memory
  scsi_controller   = "virtio-scsi-pci"

  disks {
    disk_size    = var.disk_size
    format       = "raw"
    storage_pool = var.storage_pool
    type         = "virtio"
  }

  network_adapters {
    model  = "virtio"
    bridge = var.network_bridge
  }

  boot_command = [
    "e<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<f10>"
  ]

  http_content = {
    "/user-data" = templatefile("${path.root}/http/user-data.pkrtpl", {
      user      = var.packer_username
      pass_hash = var.packer_password_hash
    })
    "/meta-data" = ""
  }

  ssh_username = var.packer_username
  ssh_password = var.packer_password_plain
  ssh_timeout  = "20m"
}

# ============================================================
# Build
# ============================================================

build {
  sources = ["source.proxmox-iso.ubuntu_2404"]

  # Limpieza: eliminar usuario temporal, claves SSH y machine-id
  # para que cada VM clonada desde esta plantilla sea única.
  provisioner "shell" {
    execute_command = "echo '${var.packer_password_plain}' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "userdel -r ${var.packer_username} || true",
      "rm -f /etc/ssh/ssh_host_*",
      "truncate -s 0 /etc/machine-id",
      "rm -f /var/lib/dbus/machine-id",
      "ln -s /etc/machine-id /var/lib/dbus/machine-id || true",
      "apt-get clean"
    ]
  }
}
