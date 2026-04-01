# Capa: templates/

Gestiona la **creación de VM plantillas** en Proxmox.  
Una VM plantilla es una VM marcada con `template = true` que sirve como origen para clonados rápidos.

## Responsabilidad

- Crear VMs de Proxmox marcadas como plantilla (`template = true`, `started = false`).
- Leer el `file_id` de la imagen base desde el estado de `images/` via `terraform_remote_state`.
- Exponer los VM IDs de las plantillas creadas para que `deploy/` los use al clonar.
- **No** despliega VMs de producción/desarrollo.

## Dependencias

- Requiere que `images/` haya descargado la imagen referenciada por `image_key`.
- Si `images/terraform.tfstate` no existe, `try()` devuelve `{}` y el apply fallará al intentar resolver el `image_key`.

## Comandos

```bash
make init-templates       # Inicializa el directorio templates/
make build-templates      # Crea las plantillas declaradas en el tfvars
make destroy-templates    # Elimina las plantillas del estado (y de Proxmox)
```

> **Precaución**: destruir una plantilla que tenga VMs clonadas activas **no** elimina esas VMs, pero las desvincula de la plantilla original.

## Configuración

Edita `templates/dev.tfvars` y añade entradas al mapa `templates`:

```hcl
templates = {
  "ubuntu-noble-tpl" = {
    vm_id     = 9000
    image_key = "ubuntu-noble"   # clave en images/dev.tfvars
    cpu_cores = 2
    memory_mb = 2048
    disk_size = 20
  }
}
```

La clave (`"ubuntu-noble-tpl"`) es el **nombre corto** que se usa como `template_name` en `deploy/dev.tfvars`.

## Outputs

| Output         | Descripción |
|----------------|-------------|
| `template_ids` | Mapa `nombre_corto → VM ID numérico` (p.ej. `"ubuntu-noble-tpl" → 9000`). |

## Estado

El estado se guarda en `templates/terraform.tfstate` (local). La capa `deploy/` lo lee con `terraform_remote_state`.
