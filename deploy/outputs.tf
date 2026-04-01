output "vms_from_image_ips" {
  description = "IPs de las VMs desplegadas desde imagen"
  value       = module.vms_from_image.vm_ipv4_addresses
}

output "vms_from_clone_ips" {
  description = "IPs de las VMs desplegadas por clonado"
  value       = module.vms_from_clone.vm_ipv4_addresses
}
