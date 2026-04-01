variable "proxmox_node" {
  type        = string
  description = "Nombre del nodo Proxmox donde se desplegarán las VMs."
}

variable "vms" {
  description = "Mapa de VMs a crear. Cada clave es el nombre de la VM."
  type = map(object({
    ip        = string
    cpu_cores = number
    memory_mb = number
    disk_size = number
    image_id  = string
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

variable "bios" {
  type        = string
  description = "Tipo de BIOS de la VM."
  default     = "seabios"
}

variable "agent_enabled" {
  type        = bool
  description = "Habilitar el QEMU Guest Agent."
  default     = false
}

variable "agent_timeout" {
  type        = string
  description = "Tiempo máximo de espera para que el QEMU Guest Agent responda (ej. '5m', '15m')."
  default     = "5m"
}

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
  default     = "scsi0"
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
