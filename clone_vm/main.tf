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
	count		= var.vm_count							# Número de VMs a crear.
	name		= "${var.vm_name}-${count.index + 1}"	# Nombre asignado a la VM clonada.
	node_name	= var.proxmox_node						# Nodo Proxmox destino.
	vm_id		= var.vm_id + count.index				# ID asignado a la nueva VM.

	# Sección de clonación: crea la máquina basada en una VM template definida por 'template_vm_id'.
	clone {
		vm_id	= var.template_vm_id	# ID de la VM base o template para el clon.
		full	= true					# 'true' -> crea un clon completo (no linked clone).
	}

	# Habilita el agente QEMU Guest Agent para mejorar integración de la VM con Proxmox (p. ej. reporte de IP).
	agent {
		enabled	= true
	}

	cpu {
		cores	= var.cpu_cores
	}

	memory {
		dedicated	= var.memory_mb
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