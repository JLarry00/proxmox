# Proxmox Terraform Deployments

Este repositorio contiene la infraestructura como código (IaC) utilizando **Terraform** para aprovisionar y gestionar máquinas virtuales dentro de un entorno **Proxmox Virtual Environment (VE)**.

El repositorio está dividido en diferentes enfoques o módulos según la estrategia de creación de la máquina virtual.

## 📂 Estructura del Proyecto

- **`dwnld_image/`**: Configuración para crear una VM descargando automáticamente una imagen Cloud-Init (ISO/Qcow) desde una URL remota y almacenándola en el datastore local de Proxmox antes de aprovisionar.
- **`local_image/`**: Configuración para crear una VM a partir de una imagen que ya se encuentra localmente en el servidor de Proxmox.
- **`clone_vm/`**: Configuración enfocada en clonar una plantilla (Template) o máquina virtual ya existente en Proxmox.
- **`scripts/`**: Contiene scripts bash auxiliares para la automatización de tareas en Git (commit y push).
- **`makefile`**: Proporciona comandos cortos y fáciles de recordar para automatizar la subida de cambios al repositorio.
- **`OLD-packer-terraform/`**: Directorio heredado con configuraciones previas basadas en Packer y Terraform.

## 🚀 Requisitos Previos

1. **Terraform** instalado en tu máquina local.
2. Acceso a un nodo de **Proxmox VE** configurado y con un usuario/API Token que tenga permisos suficientes para crear máquinas virtuales, gestionar almacenamiento y redes.
3. El proveedor de Proxmox para Terraform (`bpg/proxmox` u otro similar que se esté utilizando en los archivos `main.tf`).

## ⚠️ Importante: Variables de Entorno (Autenticación)

**¡NO intentes ejecutar `terraform plan` o `terraform apply` sin antes configurar la autenticación hacia tu servidor Proxmox!** 

El proveedor de Proxmox necesita credenciales para conectarse a la API. Para no quemar (hardcodear) contraseñas o tokens directamente en los archivos `.tf`, se deben exportar como variables de entorno en tu terminal antes de ejecutar Terraform.

Si utilizas el proveedor `bpg/proxmox`, exporta las siguientes variables según el método de autenticación que prefieras:

**Autenticación con API Token (Recomendado):**
```bash
export PROXMOX_VE_ENDPOINT="https://<TU_IP_DE_PROXMOX>:8006/"
export PROXMOX_VE_API_TOKEN="usuario@pam!nombre_token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# Si tu Proxmox tiene un certificado autofirmado:
export PROXMOX_VE_INSECURE="true"
```

**O si los archivos `.tf` esperan variables de Terraform específicas:**
```bash
export TF_VAR_proxmox_api_token="usuario@pam!nombre_token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Asegúrate de ejecutar estos `export` en la misma ventana de terminal donde vas a lanzar los comandos de Terraform.

## 🛠️ Uso de Terraform

Para desplegar cualquiera de los escenarios, dirígete al directorio correspondiente y ejecuta los comandos habituales de Terraform. Por ejemplo, para usar una imagen descargada:

```bash
cd dwnld_image
terraform init
terraform plan
terraform apply
```

*(Nota: Asegúrate de revisar y ajustar las variables dentro de los bloques `variable` de cada `main.tf` según tu entorno, como el nombre del nodo `proxmox_node`, el bridge de red `network_bridge`, etc.)*

## ⚙️ Makefile y Git Automation

El proyecto incluye un `makefile` que utiliza la lógica dentro de la carpeta `scripts/` para simplificar la gestión de commits y push a Git.

### Comandos Disponibles:

- `make commit m="tu mensaje"` : Agrega los cambios (`git add .`) y hace commit con el mensaje indicado. Si no envías mensaje y hay cambios, te pedirá que ingreses uno.
- `make fcommit` : Realiza un commit forzado con un mensaje predeterminado (`makefile: add - commit - push`) y sin pedir confirmación (solo si hay cambios).
- `make push` : Hace el commit (pidiéndote mensaje si hay cambios sueltos) y automáticamente ejecuta `git push`.
- `make fpush` : Ejecuta la misma lógica que `fcommit` seguido de un `git push` inmediato.
- `make help` : Muestra en consola la ayuda de los comandos disponibles.

---
*Documentación generada y mantenida para estandarizar los despliegues de infraestructura en Proxmox.*
