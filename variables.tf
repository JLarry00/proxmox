####################################
# Definición de variables globales #
####################################

# URL de acceso a la API de Proxmox, incluyendo protocolo, IP/host y puerto.
variable "proxmox_endpoint" {
	type	= string
}

# Token de acceso a la API de Proxmox. Marcada como sensible para proteger la credencial.
variable "proxmox_api_token" {
	type		= string
	sensitive	= true
}

# Nombre del nodo Proxmox donde se desplegará la VM.
variable "proxmox_node" {
	type	= string
}

# Nombre de la VM a crear.
variable "vm_name" {
	type	= string
}

# ID único para identificar la nueva VM.
variable "vm_id" {
	type	= number
}

# Número de VMs a crear.
variable "vm_count" {
	type	= number
}

# Tamaño del disco en GB.
variable "disk_size" {
	type	= number
}

# Número de núcleos (cores) de CPU.
variable "cpu_cores" {
	type	= number
}

# Cantidad de memoria RAM en Megabytes (MB).
variable "memory_mb" {
	type	= number
}

# Bridge de red de Proxmox al que se conectará la VM.
variable "network_bridge" {
	type	= string
}

# Usuario de acceso a la VM mediante Cloud-Init.
variable "vm_username" {
	type	= string
}

# Contraseña para el usuario anterior. Marcada como sensible.
variable "vm_password" {
	type		= string
	sensitive	= true
}

# Habilitar el agente QEMU Guest Agent.
variable "agent_enabled" {
	type	= bool
}

# Datastore ID donde se almacenará la imagen LXC.
variable "CT_template_datastore_id" {
	type	= string
}

# Datastore ID donde se almacenará el disco de la VM.
variable "CT_disk_datastore_id" {
	type	= string
}

# Lista de IPs a asignar a los contenedores LXC.
variable "lxc_ips" {
  type        = list(string)
  description = "Lista exacta de IPs (con formato CIDR) a asignar. Define la cantidad de contenedores a crear."
  # Ejemplo de uso al ejecutar: terraform apply -var 'lxc_ips=["172.16.20.15/24", "172.16.20.22/24"]'
}

################################################
# Variables exclusivas para clonar desde molde #
################################################

# ID de la VM plantilla/original desde la que se hará el clon.
variable "template_vm_id" {
	type	= number
}

###############################################
# Variables exclusivas para imagen descargada #
###############################################

# URL desde donde se descargará la imagen cloud-init a utilizar como base.
variable "cloud_image_url" {
	type	= string
}

# Checksum de la imagen para validar integridad.
variable "cloud_image_checksum" {
	type	= string
}

##########################################
# Variables exclusivas para imagen local #
##########################################

# Archivo de imagen existente en Proxmox a utilizar como base para la VM.
variable "existing_image_file" {
	type		= string
	description	= "Ruta a la imagen en el sistema de archivos de Proxmox. Formato requerido: <nombre_datastore>:iso/<nombre_archivo_con_extension>"
}
