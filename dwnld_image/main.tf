#############################
# Terraform Configuration   #
#############################
terraform {
	required_providers {
		proxmox = {
			source	= "bpg/proxmox"	# Proveedor externo para Proxmox VE disponible en el Registry de Terraform.
			version	= "0.46.4"		# Especificar la versión asegura compatibilidad y reproducibilidad.
		}
	}
}

####################################
# Definición de variables globales #
####################################

# URL de acceso a la API de Proxmox, incluyendo protocolo, IP/host y puerto.
variable "proxmox_endpoint" { 
	type	= string
	default	= "https://192.168.13.13:8006/" 
}

# Token de acceso a la API de Proxmox. Marcada como sensible para proteger la credencial.
variable "proxmox_api_token" {
	type		= string
	sensitive	= true
	default		= "juan.larrondo@pve!terraform=82918061-7fd1-4c0b-8da9-24b2d5b542e7"
}

# Nombre del nodo Proxmox donde se desplegará la VM.
variable "proxmox_node" {
	type	= string
	default	= "proxmoxdev01"
}

# URL desde donde se descargará la imagen cloud-init a utilizar como base.
variable "cloud_image_url" {
	type	= string
	default	= "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

# Checksum de la imagen para validar integridad.
variable "cloud_image_checksum" {
	type	= string
	default	= "10f19c5b2b8d6470b6f9376662e49ae22442436f5fc235079a0bc4ceb18d7df5"
}

# Nombre de la VM base creada desde imagen.
variable "vm_name" {
	type	= string
	default	= "ubuntu-2204-from-image"
}

# ID único para identificar la nueva VM.
variable "vm_id" {
	type	= number
	default	= 500
}

# Número de VMs a crear.
variable "vm_count" {
	type	= number
	default	= 1
}

# Bridge de red de Proxmox al que se conectará la VM (por ejemplo, vmbr0, vmbr1).
variable "network_bridge" {
	type	= string
	default	= "vmbr1"
}

# Usuario de acceso a la VM mediante Cloud-Init.
variable "vm_username" {
	type	= string
	default	= "admin"
}

# Contraseña del usuario de Cloud-Init. Marcada como sensible.
variable "vm_password" {
	type		= string
	sensitive	= true
	default		= "admin"
}

##############################
# Configuración del provider #
##############################

provider "proxmox" {
	endpoint	= var.proxmox_endpoint
	api_token	= var.proxmox_api_token
	insecure	= true	# Deshabilita validación de certificados SSL. No recomendado en producción.
}

##############################################################
# Recurso: Descarga de la imagen cloud-init al datastore     #
##############################################################
resource "proxmox_virtual_environment_download_file" "os_image" {
	content_type		= "iso"						# Tipo de contenido a descargar.
	datastore_id		= "local"					# Datastore destino.
	node_name			= var.proxmox_node			# Nodo de Proxmox donde se almacena la imagen.
	url					= var.cloud_image_url		# URL de la imagen.
	checksum			= var.cloud_image_checksum	# Checksum para validación.
	checksum_algorithm	= "sha256"					# Algoritmo usado para validar el checksum.
}

##################################################
# Recurso: Creación de la VM desde la imagen     #
##################################################
resource "proxmox_virtual_environment_vm" "backend_node" {
	count		= var.vm_count							# Número de VMs a crear.
	name		= "${var.vm_name}-${count.index + 1}"	# Nombre asignado a la VM.
	node_name	= var.proxmox_node						# Nodo Proxmox destino.
	vm_id		= var.vm_id + count.index				# ID único para la VM.

	# Habilita el agente QEMU Guest Agent para mejor integración de la VM con Proxmox
	agent {
		enabled	= true
	}

	# Configuración del disco principal, utilizando la imagen descargada como base
	disk {
		datastore_id	= "local-lvm"
		file_id			= proxmox_virtual_environment_download_file.os_image.id
		interface		= "virtio0"
		size			= 20	# Tamaño del disco en GB.
	}

	# Configuración de la interfaz de red de la VM
	network_device {
		bridge	= var.network_bridge
	}

	# Inicialización automática de la VM usando Cloud-Init
	initialization {
		# Configuración de red: asigna dirección IP por DHCP
		ip_config {
			ipv4 {
				address	= "dhcp"
			}
		}
		# Configuración del usuario y su contraseña, inyectados mediante Cloud-Init
		user_account {
			username	= var.vm_username
			password	= var.vm_password
		}
	}
}