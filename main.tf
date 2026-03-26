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

##############################################################
# Recurso: Descarga de la plantilla LXC al datastore         #
##############################################################
resource "proxmox_virtual_environment_download_file" "lxc_template" {
  # content_type especifica el tipo de archivo que se va a descargar. 
  # En este caso, "vztmpl" indica que es una plantilla de contenedor LXC (Linux Container Template).
  content_type = "vztmpl"
  # datastore_id especifica el datastore donde se guardará el archivo descargado.
  datastore_id = var.CT_template_datastore_id
  # node_name especifica el nodo Proxmox donde se guardará el archivo descargado.
  node_name    = var.proxmox_node
  # url especifica la URL de la plantilla LXC a descargar.
  url          = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

###########################################################
# Recurso: Creación del contenedor LXC                    #
###########################################################
resource "proxmox_virtual_environment_container" "backend_node" {
	count		= var.vm_count
	name		= "${var.vm_name}-${count.index + 1}"
	node_name	= var.proxmox_node
	vm_id		= var.vm_id + count.index

	cpu {
		cores	= var.cpu_cores
	}

	memory {
		dedicated	= var.memory_mb
	}

	disk {
		datastore_id	= var.CT_disk_datastore_id
		size			= var.disk_size
	}

	network_device {
		name	= "eth0"
		bridge	= var.network_bridge
	}

	operating_system {
		template_file_id	= proxmox_virtual_environment_download_file.lxc_template.id
		type				= "ubuntu"
	}

	initialization {
		hostname	= "${var.vm_name}-${count.index + 1}"

		ip_config {
			ipv4 {
				address	= "dhcp"
			}
		}
		user_account {
			password	= var.vm_password
		}
	}
}


output "vm_ipv4_addresses" {
	description	= "Direcciones IP asignadas a las máquinas virtuales por DHCP"
	value       = [for lxc in proxmox_virtual_environment_container.backend_node : lxc.ipv4_addresses]
}