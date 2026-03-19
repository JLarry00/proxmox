# Definición de variables que se usarán para parametrizar el despliegue del recurso en Proxmox,
# permitiendo reutilización y fácil modificación de valores según el entorno o el usuario.

# Nombre del nodo Proxmox donde se desplegará la VM.
variable "proxmox_node" {
	type	= string
	default	= "proxmoxdev01"
}

# URL desde donde se descargará la imagen cloud-init.
variable "cloud_image_url" {
	type	= string
	default	= "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
}

# Checksum de la imagen para validar integridad al descargar.
variable "cloud_image_checksum" {
	type	= string
	default	= "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
}

# Nombre que se asignará a la máquina virtual creada.
variable "vm_name" {
	type	= string
	default	= "ubuntu-2204-base-image"
}

# ID único de la VM dentro del nodo Proxmox.
variable "vm_id" {
	type	= number
	default	= 500
}

# Nombre del bridge de red de Proxmox al que se conectará la VM (ejemplo: vmbr0).
variable "network_bridge" {
	type	= string
	default	= "vmbr1"
}

# Nombre del usuario que se establecerá en la VM mediante Cloud-Init.
variable "vm_username" {
	type	= string
	default	= "admin"
}

# Contraseña que se asignará al usuario configurado por Cloud-Init en la VM.
variable "vm_password" {
	type	= string
	default	= "admin"
}

# Recurso que descarga la imagen (por ejemplo, una imagen ISO de cloud-init)
# y la almacena en el datastore local del nodo Proxmox indicado.
# Se especifica el tipo de contenido (iso), el datastore destino, el nodo target,
# la URL de la imagen, y el checksum para verificar la integridad de la imagen descargada.
resource "proxmox_virtual_environment_download_file" "os_image" {
	content_type		= "iso"
	datastore_id		= "local"
	node_name			= var.proxmox_node
	url					= var.cloud_image_url
	checksum			= var.cloud_image_checksum
	checksum_algorithm	= "sha256"	# Algoritmo utilizado para validar el checksum.
}

# Recurso principal que define la máquina virtual a crear en el entorno de Proxmox.
resource "proxmox_virtual_environment_vm" "backend_node" {
	name		= var.vm_name		# Nombre de la VM.
	node_name	= var.proxmox_node	# Nodo Proxmox en el que se va a crear la VM.
	vm_id		= var.vm_id			# ID único de la VM dentro del nodo.

	# Sección para configurar el disco de la VM:
	# - Se define sobre qué datastore se va a crear el disco ('local-lvm').
	# - 'file_id' enlaza al recurso que descargó la imagen, para utilizarla como disco principal.
	# - 'interface' es el tipo de controladora virtual (virtio0 es recomendado para Linux).
	# - 'size' define el tamaño del disco en GB.
	disk {
		datastore_id	= "local-lvm"
		file_id			= proxmox_virtual_environment_download_file.os_image.id
		interface		= "virtio0"
		size			= 20	# Tamaño del disco principal en GB.
	}

	# Configuración de la interfaz de red:
	# - Se especifica a qué bridge se conectará la VM,
	# lo que define cómo se conectará a la red física/virtual.
	network_device {
		bridge	= var.network_bridge
	}

	# Configuración de inicialización de la VM usando Cloud-Init:
	# Permite la personalización automática de la VM recién creada tras su primer arranque.
	initialization {

		# Configuración de red mediante IP dinámica por DHCP para IPv4.
		ip_config {
			ipv4 {
				address	= "dhcp"
			}
		}
		# Configuración del usuario de acceso inicial en la VM:
		# - 'username' y 'password' permiten inyectar credenciales sin modificar la imagen base.
		user_account {
			username	= var.vm_username
			password	= var.vm_password
		}
	}
}