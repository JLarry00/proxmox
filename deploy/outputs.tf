output "vms_from_image_ips" {
  description = "IPs de las VMs desplegadas desde imagen local"
  value       = module.vms_from_image.vm_ipv4_addresses
}

output "vms_from_clone_ips" {
  description = "IPs de las VMs desplegadas por clonado"
  value       = module.vms_from_clone.vm_ipv4_addresses
}

output "vms_from_download_ips" {
  description = "IPs de las VMs desplegadas desde imagen descargada"
  value       = module.vms_from_download.vm_ipv4_addresses
}
