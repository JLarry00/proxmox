##########################
# Terraform Configuration #
##########################
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

# Nombre del nodo Proxmox donde se desplegará la VM clonada.
variable "proxmox_node" {
	type	= string
	default	= "proxmoxdev01"
}

# ID de la VM plantilla/original desde la que se hará el clon.
variable "template_vm_id" {
	type	= number
	default	= 400
}

# Nombre a asignar a la nueva VM clonada.
variable "vm_name" {
	type	= string
	default	= "ubuntu-2204-clone-vm"
}

# ID único para identificar la nueva VM en Proxmox. Debe ser distinto de otras VMs en el mismo nodo.
variable "vm_id" {
	type	= number
	default	= 500
}

# Bridge de red de Proxmox al que se conectará la VM (por ejemplo, vmbr0, vmbr1).
variable "network_bridge" {
	type	= string
	default	= "vmbr1"
}

# Usuario por defecto a crear mediante Cloud-Init en la VM.
variable "vm_username" {
	type	= string
	default	= "admin"
}

# Contraseña para el usuario anterior. Por seguridad marcada como sensible.
variable "vm_password" {
	type		= string
	sensitive	= true
	default		= "admin"
}

##############################
# Configuración del provider #
##############################

# Configuración del proveedor de Proxmox con los datos provistos.
provider "proxmox" {
	endpoint	= var.proxmox_endpoint
	api_token	= var.proxmox_api_token
	insecure	= true		# Deshabilita validación de certificados SSL. No recomendado en producción.
}

####################################################
# Recurso: Clonación y configuración de la VM      #
####################################################

# Este recurso clona una VM existente (normalmente configurada como plantilla en Proxmox)
# y aplica parámetros de red y acceso con Cloud-Init.
resource "proxmox_virtual_environment_vm" "backend_node" {
	name		= var.vm_name		# Nombre asignado a la VM clonada.
	node_name	= var.proxmox_node	# Nodo Proxmox destino.
	vm_id		= var.vm_id			# ID asignado a la nueva VM.

	# Sección de clonación: crea la máquina basada en una VM template definida por 'template_vm_id'.
	clone {
		vm_id	= var.template_vm_id	# ID de la VM base o template para el clon.
		full	= true					# 'true' -> crea un clon completo (no linked clone).
	}

	# Habilita el agente QEMU Guest Agent para mejorar integración de la VM con Proxmox (p. ej. reporte de IP).
	agent {
		enabled	= true
	}

	# Configura la interfaz de red, conectando la VM al bridge especificado.
	network_device {
		bridge	= var.network_bridge
	}

	# Configura la inicialización automática de la VM usando Cloud-Init.
	initialization {
		# Configuración de red: asigna dirección IP por DHCP para IPv4.
		ip_config {
			ipv4 {
				address	= "dhcp"
			}
		}
		# Sección de cuentas de usuario: crea un usuario con las credenciales provistas.
		user_account {
			username	= var.vm_username
			password	= var.vm_password
		}
	}
}