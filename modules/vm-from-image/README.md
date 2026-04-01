# Módulo: vm-from-image

Crea una o varias VMs QEMU en Proxmox a partir de una imagen de disco (`.img` / `.qcow2`).  
El `image_id` recibido es el **file_id completo** de Proxmox (p.ej. `local:iso/ubuntu-24-04-noble.img`), resuelto por `deploy/locals.tf` antes de llamar al módulo.

## Qué hace

1. Para cada entrada del mapa `vms`, crea un recurso `proxmox_virtual_environment_file` con el snippet de Cloud-Init y un recurso `proxmox_virtual_environment_vm` que arranca desde la imagen.
2. La VM se configura con IP estática, CPU, RAM y tamaño de disco por VM.
3. Cloud-Init instala `qemu-guest-agent` y lo activa, permitiendo que Proxmox recupere la IP real de la VM.

## Variables principales

| Variable           | Tipo          | Descripción |
|--------------------|---------------|-------------|
| `vms`              | `map(object)` | Mapa de VMs. Clave = nombre de la VM. |
| `vms.image_id`     | `string`      | file_id completo en Proxmox (`local:iso/...`). |
| `vms.ip`           | `string`      | IP con máscara CIDR (`192.168.13.50/24`). |
| `vms.cpu_cores`    | `number`      | Núcleos vCPU. |
| `vms.memory_mb`    | `number`      | RAM en MiB. |
| `vms.disk_size`    | `number`      | Tamaño del disco en GiB. |
| `vm_id_base`       | `number`      | ID de Proxmox para la primera VM. Las siguientes se numeran consecutivamente. |
| `gateway`          | `string`      | Puerta de enlace de la red. |
| `agent_enabled`    | `bool`        | Activa el QEMU Guest Agent. Por defecto `false`. |

## Outputs

| Output               | Descripción |
|----------------------|-------------|
| `vm_ipv4_addresses`  | Mapa `nombre_vm → lista de IPs` reportadas por el guest agent. |

## Uso desde deploy/

Este módulo **no se llama directamente**; lo instancia `deploy/main.tf`.  
El `image_id` corto del tfvars (p.ej. `"ubuntu-24-04"`) se resuelve a su file_id completo en `deploy/locals.tf` antes de pasarlo al módulo.
