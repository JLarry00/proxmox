resource "proxmox_virtual_environment_download_file" "image" {
  for_each = var.images

  content_type       = "iso"
  datastore_id       = var.files_datastore_id
  node_name          = var.proxmox_node
  url                = each.value.url
  checksum           = each.value.checksum
  checksum_algorithm = "sha256"
  file_name          = each.value.file_name
}
