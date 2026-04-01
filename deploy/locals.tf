# =============================================================================
# Estado remoto de images/ y templates/
# Permite leer los outputs de esas capas sin acoplamiento de código.
# try() garantiza que deploy/ funcione aunque images/ o templates/ no
# estén inicializados todavía (primera ejecución).
# =============================================================================

data "terraform_remote_state" "images" {
  backend = "local"
  config = {
    path = "${path.root}/../images/terraform.tfstate"
  }
}

data "terraform_remote_state" "templates" {
  backend = "local"
  config = {
    path = "${path.root}/../templates/terraform.tfstate"
  }
}

locals {
  # -------------------------------------------------------------------------
  # Imágenes "estáticas" — ya presentes en el nodo Proxmox sin descargar.
  # Clave: nombre corto  /  Valor: file_id completo tal como lo devuelve Proxmox.
  # -------------------------------------------------------------------------
  static_images = {
    # Imágenes ya presentes en Proxmox sin pasar por images/.
    # "mi-imagen" = "local:iso/mi-imagen.img"
  }

  # -------------------------------------------------------------------------
  # Fusión estáticas + descargadas (images/ tiene prioridad si hay colisión)
  # -------------------------------------------------------------------------
  all_image_ids = merge(
    local.static_images,
    try(data.terraform_remote_state.images.outputs.image_ids, {})
  )

  # -------------------------------------------------------------------------
  # IDs de plantillas procedentes de templates/
  # -------------------------------------------------------------------------
  all_template_ids = try(data.terraform_remote_state.templates.outputs.template_ids, {})
}
