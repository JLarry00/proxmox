# =============================================================================
# Proxmox — conexión al hipervisor
# =============================================================================

variable "proxmox_endpoint" {
  type        = string
  description = "URL de acceso a la API de Proxmox, incluyendo protocolo, IP/host y puerto."
}

variable "proxmox_api_token" {
  type        = string
  description = "Token de acceso a la API de Proxmox."
  sensitive   = true
}

variable "proxmox_ssh_password" {
  type        = string
  description = "Contraseña SSH del usuario root del nodo Proxmox."
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Nombre del nodo Proxmox donde se desplegarán las VMs."
}

# =============================================================================
# Mapa de VMs a desplegar
# =============================================================================

variable "vms" {
  description = "Mapa de VMs a crear. Cada clave es el nombre de la VM."
  type = map(object({
    ip        = string
    cpu_cores = number
    memory_mb = number
    disk_size = number
    os_image  = string
  }))
}

# =============================================================================
# Máquina virtual — identidad
# =============================================================================

variable "vm_id_base" {
  type        = number
  description = "ID base para la primera VM; las siguientes incrementan según el índice en el mapa."
}

# =============================================================================
# Máquina virtual — red (invitada)
# =============================================================================

variable "network_bridge" {
  type        = string
  description = "Bridge de red de Proxmox para las VMs."
}

variable "gateway" {
  type        = string
  description = "Puerta de enlace por defecto para las VMs."
}

variable "dns_servers" {
  type        = list(string)
  description = "Lista de servidores DNS."
}

# =============================================================================
# Máquina virtual — firmware y guest agent
# =============================================================================

variable "bios" {
  type        = string
  description = "Tipo de BIOS de la VM."
}

variable "agent_enabled" {
  type        = bool
  description = "Habilitar el QEMU Guest Agent."
}

# =============================================================================
# Máquina virtual — almacenamiento
# =============================================================================

variable "disk_datastore_id" {
  type        = string
  description = "Datastore donde se almacenan los discos de las VMs."
}

variable "files_datastore_id" {
  type        = string
  description = "Datastore para archivos auxiliares (snippets de cloud-init)."
}

variable "disk_interface" {
  type        = string
  description = "Interfaz del disco (virtio, scsi, etc.)."
}

# =============================================================================
# Máquina virtual — acceso inicial (cloud-init)
# =============================================================================

variable "vm_username" {
  type        = string
  description = "Usuario inicial en la VM (cloud-init)."
}

variable "vm_password" {
  type        = string
  description = "Contraseña del usuario inicial."
  sensitive   = true
}
