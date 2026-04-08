# proxmox-terraform

Infraestructura como código para desplegar VMs en Proxmox VE con Terraform.  
Organizado en tres capas independientes con estados separados y comunicación explícita entre ellas.

---

## Arquitectura general

```
proxmox/
├── images/        ← Capa 1: descarga imágenes de disco en Proxmox
├── templates/     ← Capa 2: crea VM plantillas a partir de imágenes
├── deploy/        ← Capa 3: despliega VMs activas (dev / pro)
├── modules/       ← Módulos reutilizables (instanciados por deploy/)
│   ├── vm-from-image/
│   └── vm-from-clone/
└── scripts/       ← Scripts de entorno y utilidades Git
```

### Por qué tres capas

Cada capa tiene un ciclo de vida distinto:

| Capa        | ¿Con qué frecuencia cambia? | Destruirla accidentalmente sería... |
|-------------|----------------------------|--------------------------------------|
| `images/`   | Raramente                  | Perder las imágenes descargadas      |
| `templates/`| Raramente                  | Invalidar todos los clones futuros   |
| `deploy/`   | Con frecuencia             | Destruir solo las VMs activas        |

Al tener estados separados, un `make destroy` en `deploy/` **nunca** afecta a las imágenes ni a las plantillas.

---

## Flujo de trabajo completo

### 1. Primera vez: preparar entorno

```bash
# Opción A: local, con script ignorado por git
cp scripts/env-dev.sh.example scripts/env-dev.sh
# Edita scripts/env-dev.sh con tu endpoint, API token, etc.

# Opción B: shell actual o pipeline CI/CD
export PROXMOX_VE_ENDPOINT="https://proxmox-dev.ejemplo:8006/"
export PROXMOX_VE_API_TOKEN="usuario@pve!terraform=token"
export TF_VAR_proxmox_ssh_password="********"
export TF_VAR_proxmox_node="proxmoxdev01"
```

Los comandos `make` intentan cargar `scripts/env-<entorno>.sh` si existe. Si no existe, usan directamente las variables ya exportadas por tu shell o runner.

### 2. (Opcional) Descargar imágenes

Solo necesario si quieres usar imágenes descargadas desde internet.  
Las imágenes **estáticas** (ya en Proxmox) se declaran directamente en `deploy/locals.tf`.

```bash
# Edita images/dev.tfvars: añade entradas al mapa `images`
make init-images
make download-images
```

### 3. (Opcional) Crear plantillas

Solo necesario si vas a usar `vms_from_clone`.

```bash
# Edita templates/dev.tfvars: añade entradas al mapa `templates`
make init-templates
make build-templates
```

### 4. Desplegar VMs

```bash
# Edita deploy/dev.tfvars: configura vms_from_image y/o vms_from_clone
make use-dev     # Establece entorno activo
make init        # Inicializa deploy/ (solo la primera vez o tras cambios de provider)
make plan        # Previsualiza cambios
make apply       # Aplica
```

### 5. Destruir VMs

```bash
make destroy     # Solo destruye las VMs de deploy/
                 # Las imágenes y plantillas permanecen intactas
```

### 6. Pipeline / CI-CD

Para automatizar despliegues, exporta las mismas variables de entorno en el runner y usa los targets no interactivos:

```bash
make use-dev
make ci-init
make ci-plan
make ci-apply
```

Para producción:

```bash
make use-pro
make ci-init
make ci-plan
make ci-apply
```

Los targets `ci-*` ejecutan Terraform con `-input=false` y, en `apply` y `destroy`, con `-auto-approve`.

---

## Comandos `make` disponibles

```bash
make help        # Lista todos los comandos disponibles
```

### Selección de entorno

```bash
make use-dev     # Activa entorno dev (se guarda en .terraform-env)
make use-pro     # Activa entorno pro
```

### Capa deploy/

```bash
make init        # terraform init en deploy/
make plan        # terraform plan (sin confirmación en dev)
make apply       # terraform apply (pide confirmación siempre)
make destroy     # terraform destroy (pide confirmación siempre)

# Atajos por entorno:
make plan-dev / plan-pro
make apply-dev / apply-pro
make destroy-dev / destroy-pro

# Sin confirmación (solo dev):
make fapply / fdestroy
make fapply-dev / fdestroy-dev

# CI/CD:
make ci-init / ci-plan / ci-apply / ci-destroy
```

### Capa images/

```bash
make init-images
make download-images
make destroy-images
```

### Capa templates/

```bash
make init-templates
make build-templates
make destroy-templates
```

---

## Catálogo de imágenes

`deploy/locals.tf` define `static_images`: imágenes ya presentes en Proxmox que **no** necesitan descargarse.  
Las imágenes descargadas por `images/` se fusionan automáticamente con este catálogo.

En `deploy/dev.tfvars`, usa el nombre corto del catálogo como `image_id`:

```hcl
vms_from_image = {
  "mi-vm" = {
    ip        = "192.168.13.50/24"
    cpu_cores = 2
    memory_mb = 4096
    disk_size = 32
    image_id  = "ubuntu-24-04"   # nombre corto del catálogo
  }
}
```

---

## Credenciales

Las credenciales **nunca** van en los `.tfvars`. Se inyectan como variables de entorno, ya sea desde `scripts/env-dev.sh` / `scripts/env-pro.sh` en local, o desde variables protegidas del pipeline.

| Variable de entorno       | Descripción |
|---------------------------|-------------|
| `PROXMOX_VE_ENDPOINT`     | URL de la API de Proxmox (`https://host:8006`) |
| `PROXMOX_VE_API_TOKEN`    | Token de API (`user@realm!token=secret`) |
| `TF_VAR_proxmox_ssh_password` | Contraseña SSH del nodo (para uploads via SSH) |
| `TF_VAR_proxmox_node`     | Nombre del nodo Proxmox (`proxmoxdev01`) |

Si falta alguna de estas variables, el `makefile` aborta antes de invocar Terraform.

---

## READMEs por capa

- [images/README.md](images/README.md)
- [templates/README.md](templates/README.md)
- [deploy/README.md](deploy/README.md)
- [modules/README.md](modules/README.md)
  - [modules/vm-from-image/README.md](modules/vm-from-image/README.md)
  - [modules/vm-from-clone/README.md](modules/vm-from-clone/README.md)

---

## Estado Terraform

Cada capa tiene su propio `terraform.tfstate` local:

```
images/terraform.tfstate
templates/terraform.tfstate
deploy/terraform.tfstate
```

`templates/` y `deploy/` leen el estado de las capas inferiores via `terraform_remote_state` con `try()` para degradar graciosamente si la capa inferior aún no existe.

> Para equipos o CI/CD, se recomienda migrar a un backend remoto (S3, Terraform Cloud, etc.) para cada capa.
