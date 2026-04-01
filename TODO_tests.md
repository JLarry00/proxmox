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
- [ ] Verificar que tras un segundo `make apply` sin cambios → "No changes"
- [ ] `make destroy` — destruye las VMs pero la imagen permanece en Proxmox
- [ ] `make download-images` después del destroy → confirmar que NO re-descarga (idempotente)

---

## Flujo 2: templates/ → vm-from-clone

- [ ] `make init-templates`
- [ ] Añadir una entrada a `templates/dev.tfvars` (p.ej. VM ID 9000, `image_key = "ubuntu-24-04"`)
- [ ] `make build-templates` — crea la VM plantilla en Proxmox
- [ ] Verificar en la UI de Proxmox que aparece marcada como "template"
- [ ] En `deploy/dev.tfvars`: activar `vms_from_clone` con `template_name` apuntando a la plantilla
- [ ] `make apply` — clona la plantilla y levanta la VM
- [ ] Verificar que la VM clonada arranca y es accesible por SSH
- [ ] `make destroy` — destruye las VMs clonadas, la plantilla debe permanecer
- [ ] `make destroy-templates` — elimina la plantilla; verificar que desaparece de Proxmox

---

## Flujo 3: flujo completo 3 capas (images/ → templates/ → deploy/ clone)

- [ ] Partir de estado limpio (sin recursos en ninguna capa)
- [ ] `make init-images && make download-images`
- [ ] `make init-templates && make build-templates`
- [ ] `make init && make apply` con `vms_from_clone`
- [ ] Verificar IPs en el output `vms_from_clone_ips`
- [ ] `make destroy` → solo VMs
- [ ] `make destroy-templates` → solo plantilla
- [ ] `make destroy-images` → imagen eliminada de Proxmox

---

## Flujo 4: combinado (vm-from-image + vm-from-clone simultáneo)

- [ ] En `deploy/dev.tfvars`: tener entradas en `vms_from_image` Y en `vms_from_clone` a la vez
- [ ] `make plan` — verificar que el plan muestra recursos de ambos módulos
- [ ] `make apply` — ambos grupos de VMs se crean
- [ ] Verificar que `vms_from_image_ips` y `vms_from_clone_ips` en el output tienen valores
- [ ] `make destroy` — destruye todas, sin tocar imagen ni plantilla

---

## Flujo 5: makefile — confirmaciones y seguridad

- [ ] `make apply` en entorno dev → pide confirmación una vez
- [ ] `make apply` en entorno dev → responder "N" → cancela sin error (`make: ***` no aparece)
- [ ] `make fapply` en entorno dev → aplica sin confirmación
- [ ] `make use-pro && make fapply` → debe bloquearse con mensaje de error
- [ ] `make apply-pro` → muestra recuadro rojo de advertencia y pide confirmación
- [ ] `make apply-pro` → responder "N" → cancela sin error
- [ ] `make plan-dev` y `make plan-pro` → muestran el entorno correcto al final
- [ ] `make init` → muestra el entorno activo al final (sin pedir confirmación)

---

## Flujo 6: destroy-images con VMs activas

- [ ] Tener VMs en `deploy/` usando una imagen de `images/`
- [ ] `make destroy-images` — Terraform debe permitirlo (estados separados)
- [ ] Verificar que las VMs existentes siguen funcionando (el disco ya estaba clonado)
- [ ] Confirmar que un nuevo `make apply` fallaría al no encontrar la imagen (image_id resuelto a vacío)

---

## Flujo 7: comportamiento con estado remoto inexistente

- [ ] Eliminar `templates/terraform.tfstate` manualmente
- [ ] `make plan` → debe funcionar sin errores (actualmente falla — bug conocido, requiere state previo)
- [ ] Si falla: ejecutar `make init-templates && make build-templates` con `templates = {}` para regenerar el state vacío
- [ ] Confirmar que con el state vacío `make plan` en deploy/ funciona sin plantillas configuradas

---

## Flujo 8: múltiples VMs simultáneas

- [ ] Añadir 3+ VMs en `vms_from_image` con IPs distintas
- [ ] `make apply` — verificar si ocurre el error de race condition en snippets de cloud-init
- [ ] Si ocurre: segundo `make apply` debe completarlo sin errores
- [ ] Verificar que todas las VMs tienen IP asignada en el output

---

## Notas

- El flujo 7 es un bug conocido: `data "terraform_remote_state"` falla si el `.tfstate` no existe.
  La solución es siempre inicializar las capas inferiores aunque estén vacías.
- El checksum de la imagen Ubuntu Noble puede cambiar. Verificar periódicamente en:
  https://cloud-images.ubuntu.com/noble/current/SHA256SUMS
