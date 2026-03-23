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

	cpu {
		cores	= var.cpu_cores
	}

	memory {
		dedicated	= var.memory_mb
	}

	# Configuración del disco principal, utilizando la imagen descargada como base
	disk {
		datastore_id	= "local-lvm"
		file_id			= proxmox_virtual_environment_download_file.os_image.id
		interface		= "virtio0"
		size			= var.disk_size	# Tamaño del disco en GB.
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


output "vm_ipv4_addresses" {
	description	= "Direcciones IP asignadas a las máquinas virtuales por DHCP"
	value		= [for vm in proxmox_virtual_environment_vm.backend_node : vm.ipv4_addresses]
}