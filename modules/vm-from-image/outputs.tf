output "vm_ipv4_addresses" {
  description = "Direcciones IP asignadas a las máquinas virtuales"
  value       = { for k, vm in proxmox_virtual_environment_vm.vm : k => vm.ipv4_addresses }
}
