# main_local_image.tf

#############################
# Terraform Configuration   #
#############################
terraform {
	required_providers {
		proxmox	= {
			source	= "bpg/proxmox" # Proveedor externo para Proxmox VE disponible en el Registry de Terraform.
			version	= "0.46.4"      # Especificar la versión asegura compatibilidad y reproducibilidad.
		}
	}
}

##############################
# Configuración del provider #
##############################

provider "proxmox" {
	endpoint	= var.proxmox_endpoint
	api_token	= var.proxmox_api_token
	insecure	= true # Deshabilita validación de certificados SSL. No recomendado en producción.
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
		enabled	= var.agent_enabled
	}

	cpu {
		cores	= var.cpu_cores
	}

	memory {
		dedicated	= var.memory_mb
	}

	disk {
		datastore_id	= "local-lvm"
		file_id			= var.existing_image_file
		interface		= "virtio0"
		size			= var.disk_size
	}

	network_device {
		bridge	= var.network_bridge
	}

	initialization {
		ip_config {
			ipv4 {
				address	= "dhcp"
			}
		}
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