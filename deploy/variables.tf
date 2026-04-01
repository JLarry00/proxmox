# =============================================================================
# Proxmox — conexión (inyectadas via env-*.sh como variables de entorno)
# =============================================================================

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
  description = "VMs a desplegar desde imagen. image_id es el nombre corto definido en deploy/locals.tf."
  type = map(object({
    ip        = string
    cpu_cores = number
    memory_mb = number
    disk_size = number
    image_id  = string
  }))
  default = {}
}

variable "vms_from_clone" {
  description = "VMs a desplegar clonando la plantilla indicada en template_name."
  type = map(object({
    ip        = string
    cpu_cores = number
    memory_mb = number
  }))
  default = {}
}

# =============================================================================
# Resolución de plantilla para clonado
# =============================================================================

variable "template_name" {
  type        = string
  description = "Nombre corto de la plantilla a clonar (clave en templates/). Obligatorio si vms_from_clone no está vacío."
  default     = ""
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
