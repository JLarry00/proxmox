####################################
# Definición de variables globales #
####################################

# URL de acceso a la API de Proxmox, incluyendo protocolo, IP/host y puerto.
variable "proxmox_endpoint" {
	type						= string
	default						= "https://192.168.13.13:8006/"
}

# Token de acceso a la API de Proxmox. Marcada como sensible para proteger la credencial.
variable "proxmox_api_token" {
	type						= string
	sensitive					= true
}

# Nombre del nodo Proxmox donde se desplegará la VM.
variable "proxmox_node" {
	type						= string
	default						= "proxmoxdev01"
}

# Nombre de la VM a crear.
variable "vm_name" {
	type						= string
	default						= "ubuntu-2204-vm"
}

# ID único para identificar la nueva VM.
variable "vm_id" {
	type						= number
	default						= 500
}

# Número de VMs a crear.
variable "vm_count" {
	type						= number
	default						= 1
}

# Bridge de red de Proxmox al que se conectará la VM.
variable "network_bridge" {
	type						= string
	default						= "vmbr1"
}

# Usuario de acceso a la VM mediante Cloud-Init.
variable "vm_username" {
	type						= string
	default						= "admin"
}

# Contraseña para el usuario anterior. Marcada como sensible.
variable "vm_password" {
	type						= string
	sensitive					= true
	default						= "admin"
}

################################################
# Variables exclusivas para clonar desde molde #
################################################

# ID de la VM plantilla/original desde la que se hará el clon.
variable "template_vm_id" {
	type						= number
	default						= 400
}

###############################################
# Variables exclusivas para imagen descargada #
###############################################

# URL desde donde se descargará la imagen cloud-init a utilizar como base.
variable "cloud_image_url" {
	type						= string
	default						= "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

# Checksum de la imagen para validar integridad.
variable "cloud_image_checksum" {
	type						= string
	default						= "10f19c5b2b8d6470b6f9376662e49ae22442436f5fc235079a0bc4ceb18d7df5"
}

##########################################
# Variables exclusivas para imagen local #
##########################################

# Archivo de imagen existente en Proxmox a utilizar como base para la VM.
variable "existing_image_file" {
	type						= string
	default						= "local:iso/ubuntu-22.04-server-cloudimg-amd64.img"
	description					= "Ruta a la imagen en el sistema de archivos de Proxmox. Formato requerido: <nombre_datastore>:iso/<nombre_archivo_con_extension>"
}
