# Tests pendientes

Estado actual de los estados Terraform:
- `images/`    → 1 recurso (imagen descargada) ✓
- `templates/` → 1 recurso (plantilla creada)  — pendiente de verificar
- `deploy/`    → 4 recursos (VMs activas)       ✓

---

## Flujo 1: vm-from-image con imagen descargada (images/ → deploy/)

- [x] `make init-images`
- [x] `make download-images` — descarga `noble-server-cloudimg-amd64.img`
- [x] `make init`
- [x] `make apply` con `vms_from_image` activo — VMs arrancadas y accesibles
- [x] Verificar que tras un segundo `make apply` sin cambios → "No changes"
- [x] `make destroy` — destruye las VMs pero la imagen permanece en Proxmox
- [x] `make download-images` después del destroy → confirmar que NO re-descarga (idempotente)

---

## Flujo 2: templates/ → vm-from-clone

- [x] `make init-templates`
- [x] Añadir una entrada a `templates/dev.tfvars` (p.ej. VM ID 9000, `image_key = "ubuntu-24-04"`)
- [x] `make build-templates` — crea la VM plantilla en Proxmox
- [x] Verificar en la UI de Proxmox que aparece marcada como "template"
- [x] En `deploy/dev.tfvars`: activar `vms_from_clone` con `template_name` apuntando a la plantilla
- [x] `make apply` — clona la plantilla y levanta la VM
- [x] Verificar que la VM clonada arranca y es accesible por SSH
- [x] `make destroy` — destruye las VMs clonadas, la plantilla debe permanecer
- [x] `make destroy-templates` — elimina la plantilla; verificar que desaparece de Proxmox

---

## Flujo 3: flujo completo 3 capas (images/ → templates/ → deploy/ clone)

- [x] Partir de estado limpio (sin recursos en ninguna capa)
- [x] `make init-images && make download-images`
- [x] `make init-templates && make build-templates`
- [x] `make init && make apply` con `vms_from_clone`
- [x] Verificar IPs en el output `vms_from_clone_ips`
- [x] `make destroy` → solo VMs
- [x] `make destroy-templates` → solo plantilla
- [x] `make destroy-images` → imagen eliminada de Proxmox

---

## Flujo 4: combinado (vm-from-image + vm-from-clone simultáneo)

- [ ] En `deploy/dev.tfvars`: tener entradas en `vms_from_image` Y en `vms_from_clone` a la vez
- [ ] `make plan` — verificar que el plan muestra recursos de ambos módulos
- [ ] `make apply` — ambos grupos de VMs se crean
- [ ] Verificar que `vms_from_image_ips` y `vms_from_clone_ips` en el output tienen valores
- [ ] `make destroy` — destruye todas, sin tocar imagen ni plantilla

---

## Flujo 5: makefile — confirmaciones y seguridad

- [x] `make apply` en entorno dev → pide confirmación una vez
- [x] `make apply` en entorno dev → responder "N" → cancela sin error (`make: ***` no aparece)
- [x] `make fapply` en entorno dev → aplica sin confirmación
- [x] `make use-pro && make fapply` → debe bloquearse con mensaje de error
- [x] `make apply-pro` → muestra recuadro rojo de advertencia y pide confirmación
- [x] `make apply-pro` → responder "N" → cancela sin error
- [x] `make plan-dev` y `make plan-pro` → muestran el entorno correcto al final
- [x] `make init` → muestra el entorno activo al final (sin pedir confirmación)

---

## Flujo 6: destroy-images con VMs activas

- [x] Tener VMs en `deploy/` usando una imagen de `images/`
- [x] `make destroy-images` — Terraform debe permitirlo (estados separados)
- [x] Verificar que las VMs existentes siguen funcionando (el disco ya estaba clonado)
- [x] Confirmar que un nuevo `make apply` fallaría al no encontrar la imagen (image_id resuelto a vacío)

---

## Flujo 7: comportamiento con estado remoto inexistente

- [ ] Eliminar `templates/terraform.tfstate` manualmente
- [ ] `make plan` → debe funcionar sin errores (actualmente falla — bug conocido, requiere state previo)
- [ ] Si falla: ejecutar `make init-templates && make build-templates` con `templates = {}` para regenerar el state vacío
- [ ] Confirmar que con el state vacío `make plan` en deploy/ funciona sin plantillas configuradas

---

## Flujo 8: múltiples VMs simultáneas

- [x] Añadir 3+ VMs en `vms_from_image` con IPs distintas
- [x] `make apply` — verificar si ocurre el error de race condition en snippets de cloud-init
- [x] Si ocurre: segundo `make apply` debe completarlo sin errores
- [x] Verificar que todas las VMs tienen IP asignada en el output

---

## Notas

- El flujo 7 es un bug conocido: `data "terraform_remote_state"` falla si el `.tfstate` no existe.
  La solución es siempre inicializar las capas inferiores aunque estén vacías.
- El checksum de la imagen Ubuntu Noble puede cambiar. Verificar periódicamente en:
  https://cloud-images.ubuntu.com/noble/current/SHA256SUMS
