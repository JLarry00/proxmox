---
name: Reestructuración IaC
overview: Implementar la arquitectura de tres capas de Terraform (images/ → templates/ → deploy/) con separación de ciclos de vida, conexión via terraform_remote_state, fusión de vm-from-download en vm-from-image, y READMEs jerárquicos en cada nivel.
todos:
  - id: delete-vm-from-download
    content: Eliminar modules/vm-from-download/ completo
    status: pending
  - id: rename-readme
    content: Renombrar README.md → README_old.md
    status: pending
  - id: update-vm-from-image-module
    content: Modificar modules/vm-from-image/variables.tf (os_image→image_id, eliminar dns_servers) y main.tf (file_id directo)
    status: pending
  - id: create-images-dir
    content: Crear images/ con main.tf, variables.tf, outputs.tf, locals.tf, versions.tf, providers.tf, dev.tfvars, pro.tfvars
    status: pending
  - id: create-templates-dir
    content: Crear templates/ con main.tf, variables.tf, outputs.tf, locals.tf, versions.tf, providers.tf, dev.tfvars, pro.tfvars
    status: pending
  - id: create-deploy-locals
    content: Crear deploy/locals.tf con terraform_remote_state para images/ y templates/, y static_images
    status: pending
  - id: update-deploy-main
    content: "Actualizar deploy/main.tf: eliminar vms_from_download, resolver image_id via local.images, template_vm_id via local.template_ids"
    status: pending
  - id: update-deploy-variables
    content: "Actualizar deploy/variables.tf: os_image→image_id, eliminar vms_from_download/template_vm_id/dns_servers, añadir template_name"
    status: pending
  - id: update-deploy-outputs
    content: "Actualizar deploy/outputs.tf: eliminar vms_from_download_ips"
    status: pending
  - id: update-deploy-tfvars
    content: "Actualizar deploy/dev.tfvars y deploy/pro.tfvars: image_id short names, template_name, eliminar dns_servers y vms_from_download"
    status: pending
  - id: update-makefile
    content: Añadir IMAGES_DIR/TEMPLATES_DIR, targets init-images/download-images/destroy-images/init-templates/build-templates/destroy-templates al makefile
    status: pending
  - id: readme-modules-vm-from-image
    content: Crear modules/vm-from-image/README.md
    status: pending
  - id: readme-modules-vm-from-clone
    content: Crear modules/vm-from-clone/README.md
    status: pending
  - id: readme-modules
    content: Crear modules/README.md
    status: pending
  - id: readme-images
    content: Crear images/README.md
    status: pending
  - id: readme-templates
    content: Crear templates/README.md
    status: pending
  - id: readme-deploy
    content: Crear deploy/README.md
    status: pending
  - id: readme-root
    content: Crear README.md raíz nuevo con arquitectura completa
    status: pending
isProject: false
---

# Plan de implementación: Arquitectura IaC en capas

## Arquitectura resultante

```mermaid
flowchart TD
  subgraph infra [Infraestructura Proxmox]
    proxmox["Proxmox VE Node"]
  end

  subgraph layer1 [Capa 1 — images/]
    img_tfvars["images/dev.tfvars\n(url, checksum, file_name)"]
    img_main["images/main.tf\nproxmox_virtual_environment_download_file"]
    img_state["images/terraform.tfstate"]
    img_out["images/outputs.tf\n{ name → file_id }"]
  end

  subgraph layer2 [Capa 2 — templates/]
    tpl_tfvars["templates/dev.tfvars\n(image_id key, cpu, mem, disk)"]
    tpl_locals["templates/locals.tf\ntry(remote_state.images)"]
    tpl_main["templates/main.tf\nproxmox_virtual_environment_vm\ntemplate=true"]
    tpl_state["templates/terraform.tfstate"]
    tpl_out["templates/outputs.tf\n{ name → vm_id }"]
  end

  subgraph layer3 [Capa 3 — deploy/]
    dep_tfvars["deploy/dev.tfvars\n(VMs, image_id keys, template_name)"]
    dep_locals["deploy/locals.tf\ntry(remote_state.images)\ntry(remote_state.templates)"]
    dep_main["deploy/main.tf\nmodule vms_from_image\nmodule vms_from_clone"]
  end

  subgraph modules [modules/]
    mod_img["vm-from-image/\n(absorbe vm-from-download)"]
    mod_clone["vm-from-clone/\n(sin cambios)"]
  end

  img_tfvars --> img_main
  img_main --> img_state
  img_state --> img_out

  img_state -->|"terraform_remote_state"| tpl_locals
  tpl_tfvars --> tpl_locals
  tpl_locals --> tpl_main
  tpl_main --> tpl_state
  tpl_state --> tpl_out

  img_state -->|"terraform_remote_state"| dep_locals
  tpl_state -->|"terraform_remote_state"| dep_locals
  dep_tfvars --> dep_locals
  dep_locals --> dep_main

  dep_main --> mod_img
  dep_main --> mod_clone

  mod_img --> proxmox
  mod_clone --> proxmox
  img_main --> proxmox
  tpl_main --> proxmox
```



Cada capa tiene su propio estado Terraform. `make destroy` solo destruye la capa 3 (VMs). Las capas 1 y 2 son independientes y persisten.

---

## Archivos que se eliminan

- `modules/vm-from-download/` — eliminado completamente (toda la carpeta)

---

## Archivos que se renombran

- `README.md` → `README_old.md`

---

## Archivos que se modifican

### `modules/vm-from-image/variables.tf`

- En el tipo del mapa `vms`: `os_image: string` → `image_id: string`
- Eliminar variable `dns_servers` (declarada pero no usada en `main.tf`)

### `modules/vm-from-image/main.tf`

- Línea 26: `file_id = "local:iso/${each.value.os_image}.img"` → `file_id = each.value.image_id`
- El módulo recibe el `file_id` ya resuelto; no construye rutas

### `deploy/main.tf`

- Eliminar el bloque `module "vms_from_download"` completo
- `module "vms_from_image"`: pasar `vms` con `image_id` resuelto via `local.images`:

```hcl
  vms = {
    for k, v in var.vms_from_image : k => merge(v, {
      image_id = local.images[v.image_id]
    })
  }
  

```

- `module "vms_from_clone"`: `template_vm_id = local.template_ids[var.template_name]`
- Eliminar `dns_servers` del paso al módulo `vms_from_image`

### `deploy/variables.tf`

- `vms_from_image`: campo `os_image` → `image_id`
- Eliminar variable `vms_from_download`
- Eliminar variable `template_vm_id`
- Eliminar variable `dns_servers`
- Añadir `variable "template_name" { type = string; default = "" }`

### `deploy/outputs.tf`

- Eliminar `output "vms_from_download_ips"` (módulo eliminado)

### `deploy/dev.tfvars`

- En cada VM de `vms_from_image`: `os_image = "..."` → `image_id = "ubuntu-24-04"` (short name)
- Eliminar bloque `vms_from_download`
- `template_vm_id = 400` → `template_name = "ubuntu-noble-template"`
- Eliminar `dns_servers`

### `deploy/pro.tfvars`

- Mismos cambios que `dev.tfvars`: `os_image` → `image_id`, eliminar `vms_from_download`, `template_vm_id` → `template_name`, eliminar `dns_servers`

### `makefile`

- Añadir variables: `IMAGES_DIR = images`, `TEMPLATES_DIR = templates`
- Añadir targets nuevos (misma lógica de confirmación que los existentes; `destroy-images` y `destroy-templates` usan recuadro rojo):
  - `init-images`, `download-images`, `destroy-images`
  - `init-templates`, `build-templates`, `destroy-templates`
- Añadir sección en `help` para los nuevos targets
- Añadir a `.PHONY`

---

## Archivos que se crean

### `deploy/locals.tf`

```hcl
data "terraform_remote_state" "images" {
  backend = "local"
  config  = { path = "../images/terraform.tfstate" }
}
data "terraform_remote_state" "templates" {
  backend = "local"
  config  = { path = "../templates/terraform.tfstate" }
}
locals {
  static_images = {
    "ubuntu-24-04" = "local:iso/ubuntu-24-04-server-cloudimg-amd64.img"
  }
  images       = merge(local.static_images, try(data.terraform_remote_state.images.outputs.image_ids, {}))
  template_ids = try(data.terraform_remote_state.templates.outputs.template_ids, {})
}
```

El `try()` hace que `deploy/` funcione aunque `images/` o `templates/` no tengan estado aún. Solo fallará si se intenta usar una imagen descargada o template que no existe.

### `images/main.tf`

`proxmox_virtual_environment_download_file` con `for_each = var.images`, `file_name = each.value.file_name` explícito.

### `images/variables.tf`

Variables: `images` (map con `url`, `checksum`, `file_name`), `proxmox_node`, `files_datastore_id`.

### `images/outputs.tf`

```hcl
output "image_ids" {
  value = { for k, v in proxmox_virtual_environment_download_file.image : k => v.id }
}
```

### `images/versions.tf` y `images/providers.tf`

Copias de los existentes en `deploy/`.

### `images/dev.tfvars` y `images/pro.tfvars`

Entradas de imágenes con `url`, `checksum`, `file_name`. El `file_name` controlado explícitamente es el punto de sincronización con `deploy/locals.tf`.

### `templates/main.tf`

`proxmox_virtual_environment_vm` con `template = true`, `started = false`, `on_boot = false`. Disk usa `file_id = local.images[each.value.image_id]`.

### `templates/variables.tf`

Variables: `templates` (map con `vm_id`, `image_id`, `cpu_cores`, `memory_mb`, `disk_size`), `proxmox_node`, `disk_datastore_id`, `network_bridge`.

### `templates/outputs.tf`

```hcl
output "template_ids" {
  value = { for k, v in proxmox_virtual_environment_vm.template : k => v.vm_id }
}
```

### `templates/locals.tf`

Lee `images/terraform.tfstate` via `terraform_remote_state` + merge con static_images (igual que `deploy/locals.tf`).

### `templates/versions.tf` y `templates/providers.tf`

Copias de los existentes en `deploy/`.

### `templates/dev.tfvars` y `templates/pro.tfvars`

Definición de templates: `vm_id`, `image_id` (short name), hardware.

---

## READMEs — estructura jerárquica

Cada nivel explica lo propio y, al subir, añade contexto arquitectónico.

### `modules/vm-from-image/README.md`

Scope: el módulo. Inputs/outputs, qué recursos crea, qué espera recibir (`image_id` como `file_id` completo), limitaciones.

### `modules/vm-from-clone/README.md`

Scope: el módulo. Inputs/outputs, prerequisito del template, cómo funciona el cloud-init en clones.

### `modules/README.md`

Scope: la capa de módulos. Qué es un módulo Terraform en este contexto, cómo se consumen desde `deploy/`, qué módulos hay y cuándo usar cada uno. No documenta infraestructura concreta.

### `images/README.md`

Scope: la capa 1. Qué hace, variables en `dev.tfvars`, flujo (`make download-images`), cómo el `file_name` se sincroniza con `deploy/locals.tf`, qué ocurre en re-ejecuciones.

### `templates/README.md`

Scope: la capa 2. Qué hace, prerequisito de `images/`, variables en `dev.tfvars`, idempotencia, cómo el output `template_ids` llega a `deploy/`.

### `deploy/README.md`

Scope: la capa 3. Guía práctica de uso diario: cómo configurar VMs en `dev.tfvars`, el catálogo de `locals.tf`, flujo de `make apply/destroy`, cómo añadir una VM nueva. Referencias a `images/` y `templates/` cuando se necesita contexto previo.

### `README.md` (raíz, nuevo)

Scope: el proyecto completo. Incluye:

- Qué es el proyecto y qué tecnologías usa
- Diagrama de la arquitectura en capas
- Explicación del flujo de estados y `terraform_remote_state`
- Requisitos previos
- Flujo de trabajo completo (primera vez vs día a día)
- Referencia de comandos `make`
- Cómo añadir imágenes, templates y VMs nuevas
- Seguridad: credenciales, `.gitignore`
- Sección Packer (sin cambios respecto al actual)

---

## Flujo de trabajo resultante

```
# Primera vez:
make init-images && make download-images ENV=dev
make init-templates && make build-templates ENV=dev
make init && make apply ENV=dev

# Día a día:
make apply ENV=dev      # crea/modifica VMs
make destroy ENV=dev    # solo destruye VMs; imágenes y templates intactos

# Añadir una imagen nueva:
# 1. Añadir entrada en images/dev.tfvars
# 2. Añadir entrada en deploy/locals.tf (static_images)
# 3. make download-images ENV=dev

# Añadir un template nuevo:
# 1. Añadir entrada en templates/dev.tfvars
# 2. make build-templates ENV=dev
```

