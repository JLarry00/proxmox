output "vm_ipv4_addresses" {
  description = "Direcciones IP asignadas a las máquinas virtuales por DHCP"
  value       = [for vm in proxmox_virtual_environment_vm.backend_node : vm.ipv4_addresses]
}
