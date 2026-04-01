output "image_ids" {
  description = "Mapa de nombre corto → file_id completo en Proxmox. Leído por deploy/ y templates/ via terraform_remote_state."
  value       = { for k, v in proxmox_virtual_environment_download_file.image : k => v.id }
}
