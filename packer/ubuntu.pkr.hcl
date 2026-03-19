packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}



variable "proxmox_url" { type = string, default = "https://192.168.13.13:8006/api2/json" }
variable "proxmox_username" { type = string, default = "juan.larrondo@pve!terraform" }
variable "proxmox_token" { type = string, default = "82918061-7fd1-4c0b-8da9-24b2d5b542e7" }
variable "proxmox_node" { type = string, default = "proxmoxdev01" }
variable "template_vm_id" { type = number, default = 400 }
variable "disk_size" { type = string, default = "20G" }
variable "network_bridge" { type = string, default = "vmbr1" }
variable "iso_url" { type = string, default = "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso" }
variable "iso_checksum" { type = string, default = "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2" }
variable "template_name" { type = string, default = "ubuntu-2204-template-v1" }
variable "template_description" { type = string, default = "Plantilla inmutable Ubuntu 22.04" }
variable "cores" { type = number, default = 2 }
variable "memory" { type = number, default = 2048 }
variable "storage_pool" { type = string, default = "local-lvm" }
variable "boot_command" { type = list(string), default = [
    "e<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<f10>"
  ] }



source "proxmox-iso" "ubuntu_server" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  insecure_skip_tls_verify = true

  node                 = var.proxmox_node
  vm_id                = var.template_vm_id # ID reservado para la plantilla base
  vm_name              = var.template_name
  template_description = var.template_description

  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  
  # Almacenamiento y hardware
  os                       = "l26"
  cores                    = var.cores
  memory                   = var.memory
  scsi_controller          = "virtio-scsi-pci"
  
  disks {
    disk_size         = var.disk_size
    format            = "raw"
    storage_pool      = var.storage_pool
    type              = "virtio"
  }

  network_adapters {
    model    = "virtio"
    bridge   = var.network_bridge # Sustituir por la interfaz de red correspondiente (ej. localnetwork)
  }

  # Automatización de la instalación inyectando el user-data
  boot_command = var.boot_command
  http_directory = "http"
  
  ssh_username   = var.ssh_username
  ssh_password   = "Password123!"
  ssh_timeout    = "20m"
}

build {
  sources = ["source.proxmox-iso.${var.template_name}_server"]

  provisioner "shell" {
    execute_command = "echo 'Password123!' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "userdel -r admin_user || true",
      "rm -f /etc/ssh/ssh_host_*",
      "truncate -s 0 /etc/machine-id",
      "rm -f /var/lib/dbus/machine-id",
      "ln -s /etc/machine-id /var/lib/dbus/machine-id || true",
      "apt-get clean"
    ]
  }
}