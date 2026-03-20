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

# Archivo de imagen existente en Proxmox a utilizar como base para la VM.
variable "existing_image_file" {
	type    = string
	default = "local:iso/ubuntu-22.04-server-cloudimg-amd64.img"
	description = "Ruta a la imagen en el sistema de archivos de Proxmox. Formato requerido: <nombre_datastore>:iso/<nombre_archivo_con_extension>"
}

# Nombre de la VM a crear.
variable "vm_name" {
	type	= string
	default	= "ubuntu-2204-local-image"
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

# Bridge de red de Proxmox al que se conectará la VM.
variable "network_bridge" {
	type	= string
	default	= "vmbr1"
}

# Usuario de acceso a la VM mediante Cloud-Init.
variable "vm_username" {
	type	= string
	default	= "admin"
}

# Contraseña para el usuario anterior. Marcada como sensible.
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

###########################################################
# Recurso: Creación de la VM desde una imagen existente   #
###########################################################
resource "proxmox_virtual_environment_vm" "backend_node" {
	count		= var.vm_count
	name		= "${var.vm_name}-${count.index + 1}"
	node_name	= var.proxmox_node
	vm_id		= var.vm_id + count.index

	agent {
		enabled	= true
	}

	disk {
		datastore_id	= "local-lvm"
		file_id			= var.existing_image_file
		interface		= "virtio0"
		size			= 20
	}

	network_device {
		bridge	= var.network_bridge
	}

	initialization {
		ip_config {
			ipv4 {
				address = "dhcp"
			}
		}
		user_account {
			username = var.vm_username
			password = var.vm_password
		}
	}
}