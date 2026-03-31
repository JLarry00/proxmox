provider "proxmox" {
  # endpoint y api_token los lee el provider directamente de:
  #   PROXMOX_VE_ENDPOINT y PROXMOX_VE_API_TOKEN (variables de entorno)
  insecure = true

  ssh {
    agent    = false
    username = "root"
    password = var.proxmox_ssh_password
  }
}
