# Capa: images/

Gestiona la **descarga de imágenes de disco** en Proxmox.  
Es la primera capa del pipeline y su estado es leído por `templates/` y `deploy/` via `terraform_remote_state`.

## Responsabilidad

- Descargar imágenes (`.img`, `.qcow2`, `.iso`) desde URLs externas a un datastore de Proxmox.
- Exponer los `file_id` resultantes para que las capas superiores los usen sin conocer las URLs.
- **No** crea VMs ni plantillas.

## Idempotencia

Terraform solo descarga una imagen si no existe en el estado. Si ya está descargada y en el estado, `apply` no hace nada. Esto hace que `make download-images` sea seguro de ejecutar múltiples veces.

> Si la imagen existe en Proxmox pero **no** en el estado de Terraform (p.ej. fue creada manualmente), tendrás que importarla con `terraform import` o declararla como imagen estática en `deploy/locals.tf`.

## Comandos

```bash
make init-images          # Inicializa el directorio images/
make download-images      # Descarga las imágenes declaradas en el tfvars
make destroy-images       # Elimina las imágenes del estado (y de Proxmox)
```

## Configuración

Edita `images/dev.tfvars` (o `pro.tfvars`) y añade entradas al mapa `images`:

```hcl
images = {
  "ubuntu-noble" = {
    url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    checksum  = "6e7016f2c9f4d3c00f48789eb6b9043ba2172ccc1b6b1eaf3ed1e29dd3e52bb3"
    file_name = "ubuntu-24-04-noble.img"
  }
}
```

La clave (`"ubuntu-noble"`) es el **nombre corto** que se usará en `deploy/locals.tf` para fusionar con `static_images`.

## Outputs

| Output      | Descripción |
|-------------|-------------|
| `image_ids` | Mapa `nombre_corto → file_id completo` (p.ej. `"ubuntu-noble" → "local:iso/ubuntu-24-04-noble.img"`). |

## Estado

El estado se guarda en `images/terraform.tfstate` (local). Las capas `templates/` y `deploy/` lo leen con `terraform_remote_state`.
