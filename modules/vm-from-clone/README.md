# Módulo: vm-from-clone

Crea una o varias VMs QEMU en Proxmox **clonando una VM plantilla** existente.  
La plantilla puede haber sido creada manualmente o gestionada por la capa `templates/`.

## Qué hace

1. Para cada entrada del mapa `vms`, clona la plantilla indicada por `template_vm_id` (clon completo, no enlazado).
2. Aplica Cloud-Init para configurar IP estática, usuario y contraseña.
3. Si `agent_enabled = true`, espera a que el QEMU Guest Agent confirme el arranque antes de reportar el estado final.

## Variables principales

| Variable           | Tipo          | Descripción |
|--------------------|---------------|-------------|
| `vms`              | `map(object)` | Mapa de VMs. Clave = nombre de la VM. |
| `vms.ip`           | `string`      | IP con máscara CIDR. |
| `vms.cpu_cores`    | `number`      | Núcleos vCPU. |
| `vms.memory_mb`    | `number`      | RAM en MiB. |
| `template_vm_id`   | `number`      | ID numérico de Proxmox de la VM plantilla. Resuelto por `deploy/main.tf` desde `local.all_template_ids[var.template_name]`. |
| `vm_id_base`       | `number`      | ID de Proxmox para la primera VM clonada. |
| `gateway`          | `string`      | Puerta de enlace de la red. |
| `agent_enabled`    | `bool`        | Activa el QEMU Guest Agent. Por defecto `true`. |

## Prerequisito

La plantilla referenciada por `template_vm_id` debe existir en Proxmox **antes** de ejecutar `make apply`.  
Si la plantilla está gestionada por `templates/`, ejecuta primero `make build-templates`.

## Outputs

| Output               | Descripción |
|----------------------|-------------|
| `vm_ipv4_addresses`  | Mapa `nombre_vm → lista de IPs` reportadas por el guest agent. |

## Uso desde deploy/

Este módulo **no se llama directamente**; lo instancia `deploy/main.tf`.  
`template_vm_id` se resuelve automáticamente desde `local.all_template_ids[var.template_name]`.
