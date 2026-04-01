# Capa: deploy/

Gestiona el **despliegue de VMs** de trabajo (desarrollo o producción).  
Es la capa que más se ejecuta en el día a día y la única que **crea VMs activas**.

## Responsabilidad

- Instanciar los módulos `vm-from-image` y `vm-from-clone` con los parámetros del entorno.
- Resolver nombres cortos de imágenes y plantillas a IDs reales de Proxmox (via `locals.tf`).
- Leer el estado de `images/` y `templates/` para obtener los IDs sin duplicar información.

## Comandos habituales

```bash
# Desde la raíz del proyecto:
make use-dev       # Establece el entorno activo a dev
make init          # Inicializa deploy/ (descarga provider bpg/proxmox)
make plan          # Previsualiza cambios
make apply         # Aplica cambios (pide confirmación)
make destroy       # Destruye recursos (pide confirmación)

# Atajos directos sin cambiar el entorno activo:
make apply-dev
make apply-pro
```

## Estructura de archivos

| Archivo          | Propósito |
|------------------|-----------|
| `main.tf`        | Instancia los módulos `vm-from-image` y `vm-from-clone`. |
| `locals.tf`      | Lee `images/` y `templates/` via `terraform_remote_state`. Define `static_images` y fusiona catálogos. |
| `variables.tf`   | Declara todas las variables de entrada. |
| `outputs.tf`     | Expone las IPs de las VMs creadas. |
| `providers.tf`   | Configura el provider `bpg/proxmox` (credenciales via env vars). |
| `versions.tf`    | Fija la versión del provider. |
| `dev.tfvars`     | Valores para el entorno de desarrollo. |
| `pro.tfvars`     | Valores para el entorno de producción. |

## Catálogo de imágenes (`locals.tf`)

`deploy/locals.tf` define dos fuentes de imágenes que se fusionan:

1. **`static_images`**: imágenes ya presentes en Proxmox (no gestionadas por Terraform).
2. **Estado remoto de `images/`**: imágenes descargadas por la capa `images/`.

Si un nombre corto aparece en ambas fuentes, la imagen descargada tiene prioridad.

```hcl
# Ejemplo de static_images en locals.tf:
static_images = {
  "ubuntu-24-04" = "local:iso/ubuntu-24-04-noble.img"
}
```

## Configuración de VMs

En `dev.tfvars` (o `pro.tfvars`), declara las VMs usando el mapa correspondiente:

```hcl
# VMs desde imagen (image_id es el nombre corto del catálogo)
vms_from_image = {
  "mi-vm" = {
    ip        = "192.168.13.50/24"
    cpu_cores = 2
    memory_mb = 4096
    disk_size = 32
    image_id  = "ubuntu-24-04"
  }
}

# VMs clonadas (template_name es la clave en templates/dev.tfvars)
vms_from_clone = {
  "mi-vm-clone" = {
    ip        = "192.168.13.60/24"
    cpu_cores = 2
    memory_mb = 4096
  }
}
template_name = "ubuntu-noble-tpl"
```

## Estado

El estado se guarda en `deploy/terraform.tfstate` (local, independiente del de `images/` y `templates/`).
