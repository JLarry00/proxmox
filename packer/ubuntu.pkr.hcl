packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu_server" {
  proxmox_url              = "https://192.168.13.13:8006/api2/json"
  username                 = "juan.larrondo@pve!terraform"
  token                    = "juan.larrondo@pve!terraform=82918061-7fd1-4c0b-8da9-24b2d5b542e7"
  insecure_skip_tls_verify = true

  node                 = "proxmoxdev01"
  vm_id                = 400 # ID reservado para la plantilla base
  vm_name              = "ubuntu-2204-template-v1"
  template_description = "Plantilla inmutable Ubuntu 22.04"

  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
  iso_checksum     = "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
  
  # Almacenamiento y hardware
  os                       = "l26"
  cores                    = 2
  memory                   = 2048
  scsi_controller          = "virtio-scsi-pci"
  
  disks {
    disk_size         = "20G"
    format            = "raw"
    storage_pool      = "local-lvm"
    type              = "virtio"
  }

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr1" # Sustituir por la interfaz de red correspondiente (ej. localnetwork)
  }

  # Automatización de la instalación inyectando el user-data
  boot_command = [
    "e<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<f10>"
  ]
  http_directory = "http"
  
  ssh_username   = "admin_user"
  ssh_password   = "Password123!"
  ssh_timeout    = "20m"
}

build {
  sources = ["source.proxmox-iso.ubuntu_server"]
}