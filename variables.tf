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

variable "proxmox_node" {
  type        = string
  description = "Nombre del nodo Proxmox donde se desplegará la VM."
}

# =============================================================================
# Máquina virtual — identidad y cantidad de instancias
# =============================================================================

variable "vm_name" {
  type        = string
  description = "Prefijo de nombre de las VMs (se añade un sufijo numérico por instancia)."
}

variable "vm_id" {
  type        = number
  description = "ID base de la primera VM; las siguientes incrementan según el índice."
}

variable "vm_count" {
  type        = number
  description = "Número de VMs a crear (reservado / otros flujos; la raíz usa length(ip_addresses) para count)."
}

# =============================================================================
# Máquina virtual — red (invitada)
# =============================================================================

variable "network_bridge" {
  type        = string
  description = "Bridge de red de Proxmox para la VM."
}

variable "ip_addresses" {
  type        = list(string)
  description = "Lista de direcciones IPv4 con máscara (p. ej. 192.168.1.100/24). El count de instancias sigue length(ip_addresses)."
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
# Máquina virtual — cómputo, firmware y guest agent
# =============================================================================

variable "cpu_cores" {
  type        = number
  description = "Número de cores de CPU."
}

variable "memory_mb" {
  type        = number
  description = "RAM dedicada en megabytes (MB)."
}

variable "bios" {
  type        = string
  description = "Tipo de BIOS de la VM."
}

variable "agent_enabled" {
  type        = bool
  description = "Habilitar el QEMU Guest Agent."
}

# =============================================================================
# Máquina virtual — almacenamiento e imagen de disco
# =============================================================================

variable "disk_datastore_id" {
  type        = string
  description = "Datastore donde se almacenan los discos de las VMs."
}

variable "files_datastore_id" {
  type        = string
  description = "Datastore para archivos auxiliares."
}

variable "disk_interface" {
  type        = string
  description = "Interfaz del disco (virtio, scsi, etc.)."
}

variable "disk_size" {
  type        = number
  description = "Tamaño del disco en GB."
}

variable "existing_image_file" {
  type        = string
  description = "Ruta a la imagen en el sistema de archivos de Proxmox. Formato: <datastore>:iso/<archivo>"
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

# =============================================================================
# Otros flujos del repositorio (clon / imagen descargada)
# =============================================================================
# Las siguientes variables no las usa obligatoriamente el main.tf de la raíz;
# sirven para módulos o carpetas alternativas (p. ej. clone_vm, dwnld_image).

variable "template_vm_id" {
  type        = number
  description = "ID de la VM plantilla para flujos de clonado."
}

variable "cloud_image_url" {
  type        = string
  description = "URL de la imagen cloud-init base (descarga)."
}

variable "cloud_image_checksum" {
  type        = string
  description = "Checksum de la imagen para validación (descarga)."
}
