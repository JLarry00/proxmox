# =============================================================================
# Proxmox — conexión
# =============================================================================

variable "proxmox_endpoint" {
  type        = string
  description = "URL de acceso a la API de Proxmox."
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
  description = "Nombre del nodo Proxmox."
}

# =============================================================================
# Mapas de VMs por método de despliegue
# =============================================================================

variable "vms_from_image" {
  description = "VMs a desplegar desde imagen .img local."
  type = map(object({
    ip        = string
    cpu_cores = number
    memory_mb = number
    disk_size = number
    os_image  = string
  }))
  default = {}
}

variable "vms_from_clone" {
  description = "VMs a desplegar clonando una VM template."
  type = map(object({
    ip        = string
    cpu_cores = number
    memory_mb = number
  }))
  default = {}
}

variable "vms_from_download" {
  description = "VMs a desplegar descargando la imagen desde internet."
  type = map(object({
    ip             = string
    cpu_cores      = number
    memory_mb      = number
    disk_size      = number
    image_url      = string
    image_checksum = string
  }))
  default = {}
}

# =============================================================================
# Red e identidad
# =============================================================================

variable "vm_id_base" {
  type        = number
  description = "ID base para el rango de VMs."
}

variable "gateway" {
  type        = string
  description = "Puerta de enlace por defecto."
}

variable "dns_servers" {
  type        = list(string)
  description = "Lista de servidores DNS."
  default     = []
}

variable "template_vm_id" {
  type        = number
  description = "ID de la VM template para flujos de clonado."
  default     = 0
}

# =============================================================================
# Hardware y almacenamiento
# =============================================================================

variable "bios" {
  type    = string
  default = "seabios"
}

variable "agent_enabled" {
  type    = bool
  default = false
}

variable "agent_timeout" {
  type        = string
  description = "Tiempo máximo de espera para que el QEMU Guest Agent responda."
  default     = "5m"
}

variable "disk_datastore_id" {
  type        = string
  description = "Datastore para discos de VMs."
}

variable "files_datastore_id" {
  type        = string
  description = "Datastore para snippets y archivos auxiliares."
}

variable "disk_interface" {
  type    = string
  default = "scsi0"
}

variable "network_bridge" {
  type        = string
  description = "Bridge de red de Proxmox."
}

# =============================================================================
# Acceso inicial
# =============================================================================

variable "vm_username" {
  type        = string
  description = "Usuario inicial en la VM (cloud-init)."
}

variable "vm_password" {
  type      = string
  sensitive = true
}
