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
  description = "Nombre del nodo Proxmox donde se crearán las plantillas."
}

# =============================================================================
# Almacenamiento
# =============================================================================

variable "vm_datastore_id" {
  type        = string
  description = "Datastore donde se almacenan los discos de las plantillas (ej. 'local-lvm')."
}

variable "files_datastore_id" {
  type        = string
  description = "Datastore donde se encuentran las imágenes descargadas (ej. 'local')."
}

# =============================================================================
# Estado remoto de images/
# =============================================================================

variable "images_state_path" {
  type        = string
  description = "Ruta al directorio images/ para leer su terraform.tfstate via terraform_remote_state."
  default     = "../images"
}

# =============================================================================
# Definición de plantillas
# =============================================================================

variable "templates" {
  description = "Mapa de plantillas VM a crear. La clave es el nombre corto de la plantilla."
  type = map(object({
    vm_id       = number
    image_key   = string
    description = optional(string, "")
    cpu_cores   = optional(number, 2)
    memory_mb   = optional(number, 2048)
    disk_size   = optional(number, 20)
  }))
  default = {}
}
