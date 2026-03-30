provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
  # Evita que el proveedor intente usar SSH contra el nodo Proxmox
  ssh {
    agent    = false
    username = "root"
    password = "52776636"
  }
}
