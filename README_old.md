# Proxmox Terraform Deployments

Infraestructura como código (IaC) con **Terraform** y **Packer** para desplegar máquinas virtuales en **Proxmox VE**.

---

## Estructura del proyecto

```
proxmox/
├── modules/                      # Bloques reutilizables (sin credenciales)
│   ├── vm-from-image/            # Despliegue desde imagen .img local en Proxmox
│   ├── vm-from-clone/            # Clon de una VM template existente en Proxmox
│   └── vm-from-download/         # Descarga la imagen desde internet y despliega
│
├── deploy/                       # Un único conjunto de .tf — selecciona entorno con -var-file
│   ├── main.tf                   # Llama a los módulos
│   ├── providers.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── dev.tfvars                # Valores dev  (NO en git — contiene credenciales)
│   └── pro.tfvars               # Valores prod (NO en git — contiene credenciales)
│
├── packer/
│   └── ubuntu-24-04/             # Construye una VM template en Proxmox (independiente)
│
├── scripts/
│   ├── env-dev.sh                # Carga credenciales del entorno dev como variables de entorno (NO en git)
│   ├── env-pro.sh               # Carga credenciales del entorno pro (NO en git)
│   ├── commit.sh                 # Automatización de commits
│   ├── push.sh                   # Automatización de push
│   └── switch.sh                 # Cambio de rama git
│
├── OLD/                          # Backups de código anterior (solo referencia)
└── makefile                      # Comandos abreviados por entorno
```

---

## Requisitos previos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3
- [Packer](https://developer.hashicorp.com/packer/install) >= 1.9 (solo para construir templates)
- Acceso a un nodo Proxmox VE con:
  - API Token con permisos de VM, almacenamiento y red
  - Acceso SSH al nodo como `root` (requerido por el provider `bpg/proxmox`)
  - Imagen `.img` subida al datastore si se usa `vm-from-image`
  - VM template en el nodo si se usa `vm-from-clone`

---

## Flujo de trabajo

### 1. Configurar credenciales

Los scripts `env-dev.sh` y `env-pro.sh` cargan las credenciales como variables de entorno. El provider `bpg/proxmox` las lee automáticamente.

Edita `scripts/env-dev.sh` con tus datos y luego ejecuta:

```bash
source scripts/env-dev.sh
```

Variables que exporta:

| Variable de entorno | Descripción |
|---|---|
| `PROXMOX_VE_ENDPOINT` | URL del nodo Proxmox (`https://IP:8006/`) |
| `PROXMOX_VE_API_TOKEN` | Token de API (`usuario@pve!token=xxx`) |
| `TF_VAR_proxmox_ssh_password` | Contraseña SSH del root del nodo |
| `TF_VAR_proxmox_node` | Nombre del nodo Proxmox |

> Estos archivos están en `.gitignore` y nunca se suben al repositorio.

---

### 2. Configurar las VMs a desplegar

Edita `deploy/dev.tfvars`. Las VMs se definen en mapas por método de despliegue:

```hcl
# VMs desplegadas desde una imagen .img ya subida a Proxmox
vms_from_image = {
  "backend-1" = {
    ip        = "172.16.20.50/24"
    cpu_cores = 2
    memory_mb = 4096
    disk_size = 32
    os_image  = "ubuntu-24-04-server-cloudimg-amd64"  # nombre sin .img
  }
  "jenkins" = {
    ip        = "172.16.20.51/24"
    cpu_cores = 4
    memory_mb = 8192
    disk_size = 50
    os_image  = "ubuntu-24-04-server-cloudimg-amd64"
  }
}

# Para no usar un método, dejar el mapa vacío:
vms_from_clone    = {}
vms_from_download = {}
```

Cada clave del mapa es el **nombre de la VM** en Proxmox. Los IDs de VM se asignan automáticamente a partir de `vm_id_base`.

---

### 3. Desplegar con make

```bash
# Inicializar (solo la primera vez o al añadir providers)
make init ENV=dev

# Ver el plan de cambios
make plan ENV=dev

# Aplicar
make apply ENV=dev

# Destruir todo
make destroy ENV=dev
```

Sin especificar `ENV`, el valor por defecto es `dev`.

---

### 4. Desplegar directamente con Terraform

```bash
source scripts/env-dev.sh
cd deploy
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

---

## Métodos de despliegue

### `vm-from-image` — Imagen local

Requiere que la imagen `.img` esté **ya subida** al datastore `local` de Proxmox (en `local:iso/`).

Para subir una imagen manualmente:
```bash
# Desde la máquina local
scp ubuntu-24-04-server-cloudimg-amd64.img root@PROXMOX_IP:/var/lib/vz/template/iso/
```

O desde la UI de Proxmox: `Datacenter > Storage > local > ISO Images > Upload`.

### `vm-from-clone` — Clon de template

Requiere que exista una VM template en Proxmox con el ID especificado en `template_vm_id`. Puede construirse con Packer (ver sección siguiente).

### `vm-from-download` — Descarga automática

Terraform descarga la imagen directamente desde la URL indicada en cada VM y la sube al datastore de Proxmox antes de crear la VM. Más lento pero completamente automatizado.

---

## Packer — Construir templates

Packer es **independiente de Terraform**. Construye una VM template en Proxmox que luego Terraform puede clonar con `vm-from-clone`.

```bash
cd packer/ubuntu-24-04

# Inicializar plugins
packer init ubuntu.pkr.hcl

# Construir la template (requiere credenciales como variables)
packer build \
  -var "proxmox_token=TU_TOKEN" \
  -var "packer_password_plain=TU_PASS" \
  -var "packer_password_hash=\$(openssl passwd -6 TU_PASS)" \
  ubuntu.pkr.hcl
```

O usando un archivo de variables:
```bash
packer build -var-file=secrets.pkrvars.hcl ubuntu.pkr.hcl
```

El resultado es una VM template en Proxmox con el ID `template_vm_id` (por defecto `400`) que Terraform puede clonar.

---

## Makefile — referencia de comandos

| Comando | Descripción |
|---|---|
| `make init [ENV=dev\|pro]` | `terraform init` en el entorno |
| `make plan [ENV=dev\|pro]` | `terraform plan` |
| `make apply [ENV=dev\|pro]` | `terraform apply` |
| `make destroy [ENV=dev\|pro]` | `terraform destroy` |
| `make fmt` | Formatea todos los archivos `.tf` recursivamente |
| `make commit m="mensaje"` | `git add` + commit con mensaje |
| `make push` | Commit + push |
| `make switch` | Cambio interactivo de rama git |

---

## Notas importantes

- Los archivos `terraform.tfvars` y `env-*.sh` contienen credenciales y están en `.gitignore`. **Nunca se suben al repositorio.**
- El provider `bpg/proxmox` requiere acceso SSH al nodo Proxmox además de la API. Esto es necesario para subir snippets de cloud-init.
- El agente QEMU (`agent_enabled`) debe estar en `false` si la imagen base no tiene `qemu-guest-agent` instalado; de lo contrario Terraform esperará indefinidamente.
- Para producción, sustituir `vm_password` por autenticación con clave SSH pública.

---

## Pendiente

- [ ] Backend remoto para `terraform.tfstate` (PostgreSQL en LXC o similar) para trabajo en equipo con bloqueo de estado.
