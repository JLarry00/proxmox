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
  description = "Nombre del nodo Proxmox donde se descargarán las imágenes."
}

# =============================================================================
# Almacenamiento
# =============================================================================

variable "files_datastore_id" {
  type        = string
  description = "Datastore de Proxmox donde se almacenarán las imágenes descargadas (ej. 'local')."
}

# =============================================================================
# Imágenes a descargar
# =============================================================================

variable "images" {
  description = "Mapa de imágenes a descargar. La clave es el nombre corto usado como referencia en deploy/locals.tf."
  type = map(object({
    url       = string
    checksum  = string
    file_name = string
  }))
  default = {}
}
