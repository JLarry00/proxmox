resource "proxmox_virtual_environment_file" "user_data" {
  content_type = "snippets"
  datastore_id = "local"            # Ajusta al datastore de snippets en tu nodo Proxmox
  node_name    = var.proxmox_node   # Ajusta al nombre exacto de tu nodo DEV

  source_raw {
    data = templatefile("${path.module}/user-data.tftpl", {
      custom_packages = [
        "qemu-guest-agent",
        "openjdk-17-jre" # Jenkins requiere Java 17 o 21
      ]
      custom_scripts  = [
        # Descargar la clave GPG del repositorio de Jenkins
        "wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
        # Añadir el repositorio de Jenkins a las fuentes de apt
        "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
        # Actualizar repositorios e instalar Jenkins
        "apt-get update",
        "apt-get install -y jenkins",
        # Iniciar y habilitar el servicio de Jenkins
        "systemctl enable --now jenkins"
      ]
    })
    file_name = "user-data.yaml"
  }
}