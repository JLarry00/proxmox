output "template_ids" {
  description = "Mapa de nombre corto → VM ID de la plantilla. Leído por deploy/ via terraform_remote_state."
  value       = { for k, v in proxmox_virtual_environment_vm.template : k => v.vm_id }
}
