# Módulos Terraform

Contiene los módulos reutilizables que implementan los distintos métodos de despliegue de VMs.  
**Ningún módulo se ejecuta directamente.** Todos son instanciados por `deploy/main.tf`.

## Módulos disponibles

### `vm-from-image/`

Despliega VMs directamente desde una imagen de disco (`.img`).  
La imagen puede ser:
- **Estática**: ya presente en Proxmox, referenciada en `deploy/locals.tf → static_images`.
- **Descargada**: gestionada por la capa `images/` y disponible via `terraform_remote_state`.

→ Ver [vm-from-image/README.md](vm-from-image/README.md)

### `vm-from-clone/`

Despliega VMs clonando una VM plantilla existente.  
La plantilla puede haberse creado manualmente en Proxmox o gestionarse via la capa `templates/`.

→ Ver [vm-from-clone/README.md](vm-from-clone/README.md)

## Resolución de IDs

Los módulos reciben **valores ya resueltos** (file_id completo, VM ID numérico).  
La resolución de nombres cortos a IDs reales ocurre en `deploy/locals.tf` y `deploy/main.tf`, no dentro de los módulos. Esto mantiene los módulos independientes del sistema de catálogos y del estado de otras capas.

## Añadir un nuevo módulo

1. Crear directorio `modules/nuevo-modulo/`.
2. Incluir `versions.tf` con el bloque `required_providers` para `bpg/proxmox`.
3. Definir `variables.tf`, `main.tf` y `outputs.tf`.
4. Instanciar el módulo desde `deploy/main.tf`.
