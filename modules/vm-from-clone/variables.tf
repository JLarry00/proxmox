variable "proxmox_node" {
  type        = string
  description = "Nombre del nodo Proxmox donde se desplegarán las VMs."
}

variable "template_vm_id" {
  type        = number
  description = "ID de la VM plantilla desde la que se clonará."
}

variable "vms" {
  description = "Mapa de VMs a crear. Cada clave es el nombre de la VM."
  type = map(object({
    ip        = string
    cpu_cores = number
    memory_mb = number
  }))
}

variable "vm_id_base" {
  type        = number
  description = "ID base para la primera VM."
}

variable "gateway" {
  type        = string
  description = "Puerta de enlace por defecto para las VMs."
}

variable "agent_enabled" {
  type        = bool
  description = "Habilitar el QEMU Guest Agent."
  default     = true
}

variable "agent_timeout" {
  type        = string
  description = "Tiempo máximo de espera para que el QEMU Guest Agent responda (ej. '5m', '15m')."
  default     = "5m"
}

variable "disk_datastore_id" {
  type        = string
  description = "Datastore para el disco de las VMs clonadas."
}

variable "files_datastore_id" {
  type        = string
  description = "Datastore para archivos auxiliares (snippets de cloud-init)."
}

variable "network_bridge" {
  type        = string
  description = "Bridge de red de Proxmox para las VMs."
}

variable "vm_username" {
  type        = string
  description = "Usuario inicial en la VM (cloud-init)."
}

variable "vm_password" {
  type        = string
  description = "Contraseña del usuario inicial."
  sensitive   = true
}
