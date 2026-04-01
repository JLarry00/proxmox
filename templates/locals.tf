data "terraform_remote_state" "images" {
  backend = "local"
  config = {
    path = "${var.images_state_path}/terraform.tfstate"
  }
}

locals {
  # IDs de imágenes procedentes del estado de images/
  # try() devuelve {} si el estado no existe todavía (primera ejecución)
  downloaded_image_ids = try(data.terraform_remote_state.images.outputs.image_ids, {})
}
