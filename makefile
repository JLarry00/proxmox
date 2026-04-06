-include .terraform-env
ENV           ?= dev
DEPLOY_DIR     = deploy
IMAGES_DIR     = images
TEMPLATES_DIR  = templates
SHELL         := /bin/bash
# Entornos validos: dev, pro

# Colores
_Y  = \033[1;33m
_R  = \033[1;31m
_G  = \033[1;32m
_B  = \033[1;34m
_X  = \033[0m
_RB = \033[1;41;97m

# Recuadro PRO (49 chars por linea, sin acentos para alineacion exacta)
# "   !! ATENCION - ENTORNO DE PRODUCCION: PRO !!   " = 3+43+3 = 49
define _pro_box
	printf "\n$(_RB)                                                 $(_X)\n"; \
	printf   "$(_RB)   !! ATENCION - ENTORNO DE PRODUCCION: PRO !!   $(_X)\n"; \
	printf   "$(_RB)                                                 $(_X)\n\n"
endef

# Recordatorio de entorno al final de init/plan
define _env_reminder
	if [ "$(ENV)" = "pro" ]; then \
		printf "\n$(_RB)   Entorno activo : PRO   $(_X)\n\n"; \
	else \
		printf "\n$(_Y)  Entorno activo : $(ENV)$(_X)\n\n"; \
	fi
endef

all: help

help:
	@printf "\n"
	@printf "$(_B)-- Seleccion de entorno -----------------------------------------$(_X)\n"
	@printf "  make use-dev               Activa entorno dev\n"
	@printf "  make use-pro               Activa entorno pro\n"
	@printf "\n"
	@printf "$(_B)-- Terraform (entorno activo: "
	@if [ "$(ENV)" = "pro" ]; then printf "$(_RB) PRO $(_X)"; else printf "$(_Y)$(ENV)$(_X)"; fi
	@printf "$(_B)) ----------------------------$(_X)\n"
	@printf "  make init                  terraform init  (independiente del entorno)\n"
	@printf "  make plan                  terraform plan  (sin confirmacion en dev)\n"
	@printf "  make apply                 terraform apply (pide confirmacion siempre)\n"
	@printf "  make destroy               terraform destroy (pide confirmacion siempre)\n"
	@printf "\n"
	@printf "$(_B)-- Atajos por entorno -------------------------------------------$(_X)\n"
	@printf "  make plan-dev / plan-pro\n"
	@printf "  make apply-dev / apply-pro\n"
	@printf "  make destroy-dev / destroy-pro\n"
	@printf "\n"
	@printf "$(_B)-- Sin confirmacion: force (solo dev) ---------------------------$(_X)\n"
	@printf "  make fapply / fdestroy          (entorno activo, bloqueado si es pro)\n"
	@printf "  make fapply-dev / fdestroy-dev\n"
	@printf "\n"
	@printf "$(_B)-- Capa images/ ------------------------------------------------$(_X)\n"
	@printf "  make init-images           terraform init en images/\n"
	@printf "  make download-images       descarga imágenes (apply en images/)\n"
	@printf "  make destroy-images        elimina imágenes del estado de Proxmox\n"
	@printf "\n"
	@printf "$(_B)-- Capa templates/ ---------------------------------------------$(_X)\n"
	@printf "  make init-templates        terraform init en templates/\n"
	@printf "  make build-templates       crea plantillas VM (apply en templates/)\n"
	@printf "  make destroy-templates     elimina plantillas del estado de Proxmox\n"
	@printf "\n"
	@printf "$(_B)-- Git ----------------------------------------------------------$(_X)\n"
	@printf "  make fmt                   formatea el codigo\n"
	@printf "  make commit m=\"mensaje\"    git add + commit\n"
	@printf "  make fcommit m=\"mensaje\"   git add + commit (sin confirmacion)\n"
	@printf "  make push                  commit + push\n"
	@printf "  make fpush                 commit + push (sin confirmacion)\n"
	@printf "  make switch                cambiar de rama\n"
	@printf "\n"

.PHONY: use-dev use-pro init plan apply destroy \
        plan-dev plan-pro apply-dev apply-pro destroy-dev destroy-pro \
        fapply fdestroy fapply-dev fdestroy-dev \
        init-images download-images destroy-images \
        init-templates build-templates destroy-templates \
        fmt commit fcommit push fpush switch help

# ── Seleccion de entorno ───────────────────────────────────────────

use-dev:
	@echo "ENV=dev" > .terraform-env
	@printf "  Entorno activo: $(_Y)dev$(_X) — recuerda: source scripts/env-dev.sh\n"

use-pro:
	@echo "ENV=pro" > .terraform-env
	@printf "  Entorno activo: $(_RB) PRO $(_X) — recuerda: source scripts/env-pro.sh\n"

# ── init (sin entorno, muestra recordatorio al final) ─────────────

init:
	@source scripts/env-$(ENV).sh && cd $(DEPLOY_DIR) && terraform init
	@$(call _env_reminder)

# ── plan ──────────────────────────────────────────────────────────

plan:
	@_ok=yes; \
	if [ "$(ENV)" = "pro" ]; then \
		$(call _pro_box); \
		printf "  $(_R)Accion  : plan$(_X)\n\n"; \
		read -p "  Confirmar? [y/N] " _ans; \
		[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	fi; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-$(ENV).sh && cd $(DEPLOY_DIR) && terraform plan -var-file=$(ENV).tfvars; \
		$(call _env_reminder); \
	else \
		printf "  Cancelado.\n\n"; \
	fi

plan-dev:
	@source scripts/env-dev.sh && cd $(DEPLOY_DIR) && terraform plan -var-file=dev.tfvars
	@printf "\n$(_Y)  Entorno activo : dev$(_X)\n\n"

plan-pro:
	@_ok=yes; \
	$(call _pro_box); \
	printf "  $(_R)Accion  : plan$(_X)\n\n"; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-pro.sh && cd $(DEPLOY_DIR) && terraform plan -var-file=pro.tfvars; \
		printf "\n$(_RB)   Entorno activo : PRO   $(_X)\n\n"; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

# ── apply ─────────────────────────────────────────────────────────

apply:
	@_ok=yes; \
	if [ "$(ENV)" = "pro" ]; then \
		$(call _pro_box); \
		printf "  $(_R)Accion  : apply$(_X)\n\n"; \
	else \
		printf "\n$(_Y)  Entorno : $(ENV)$(_X)\n  Accion  : apply\n\n"; \
	fi; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-$(ENV).sh && cd $(DEPLOY_DIR) && terraform apply -var-file=$(ENV).tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

apply-dev:
	@_ok=yes; \
	printf "\n$(_Y)  Entorno : dev$(_X)\n  Accion  : apply\n\n"; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-dev.sh && cd $(DEPLOY_DIR) && terraform apply -var-file=dev.tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

apply-pro:
	@_ok=yes; \
	$(call _pro_box); \
	printf "  $(_R)Accion  : apply$(_X)\n\n"; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-pro.sh && cd $(DEPLOY_DIR) && terraform apply -var-file=pro.tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

# ── destroy ───────────────────────────────────────────────────────

destroy:
	@_ok=yes; \
	if [ "$(ENV)" = "pro" ]; then \
		$(call _pro_box); \
		printf "  $(_R)Accion  : destroy$(_X)\n\n"; \
	else \
		printf "\n$(_Y)  Entorno : $(ENV)$(_X)\n  Accion  : destroy\n\n"; \
	fi; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-$(ENV).sh && cd $(DEPLOY_DIR) && terraform destroy -var-file=$(ENV).tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

destroy-dev:
	@_ok=yes; \
	printf "\n$(_Y)  Entorno : dev$(_X)\n  Accion  : destroy\n\n"; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-dev.sh && cd $(DEPLOY_DIR) && terraform destroy -var-file=dev.tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

destroy-pro:
	@_ok=yes; \
	$(call _pro_box); \
	printf "  $(_R)Accion  : destroy$(_X)\n\n"; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-pro.sh && cd $(DEPLOY_DIR) && terraform destroy -var-file=pro.tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

# ── Force: sin confirmacion (solo dev) ────────────────────────────

fapply:
	@if [ "$(ENV)" = "pro" ]; then \
		printf "\n$(_R)  Force no permitido en pro.$(_X) Usa: make apply-pro\n\n"; \
	else \
		source scripts/env-$(ENV).sh && cd $(DEPLOY_DIR) && terraform apply -var-file=$(ENV).tfvars; \
	fi

fdestroy:
	@if [ "$(ENV)" = "pro" ]; then \
		printf "\n$(_R)  Force no permitido en pro.$(_X) Usa: make destroy-pro\n\n"; \
	else \
		source scripts/env-$(ENV).sh && cd $(DEPLOY_DIR) && terraform destroy -var-file=$(ENV).tfvars; \
	fi

fapply-dev:
	@source scripts/env-dev.sh && cd $(DEPLOY_DIR) && terraform apply -var-file=dev.tfvars

fdestroy-dev:
	@source scripts/env-dev.sh && cd $(DEPLOY_DIR) && terraform destroy -var-file=dev.tfvars

# ── images/ ────────────────────────────────────────────────────────

init-images:
	@source scripts/env-$(ENV).sh && cd $(IMAGES_DIR) && terraform init
	@$(call _env_reminder)

download-images:
	@_ok=yes; \
	if [ "$(ENV)" = "pro" ]; then \
		$(call _pro_box); \
		printf "  $(_R)Accion  : download-images$(_X)\n\n"; \
	else \
		printf "\n$(_Y)  Entorno : $(ENV)$(_X)\n  Accion  : download-images\n\n"; \
	fi; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-$(ENV).sh && cd $(IMAGES_DIR) && terraform apply -var-file=$(ENV).tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

destroy-images:
	@_ok=yes; \
	if [ "$(ENV)" = "pro" ]; then \
		$(call _pro_box); \
		printf "  $(_R)Accion  : destroy-images$(_X)\n\n"; \
	else \
		printf "\n$(_Y)  Entorno : $(ENV)$(_X)\n  Accion  : destroy-images\n\n"; \
	fi; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-$(ENV).sh && cd $(IMAGES_DIR) && terraform destroy -var-file=$(ENV).tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

# ── templates/ ─────────────────────────────────────────────────────

init-templates:
	@source scripts/env-$(ENV).sh && cd $(TEMPLATES_DIR) && terraform init
	@$(call _env_reminder)

build-templates:
	@_ok=yes; \
	if [ "$(ENV)" = "pro" ]; then \
		$(call _pro_box); \
		printf "  $(_R)Accion  : build-templates$(_X)\n\n"; \
	else \
		printf "\n$(_Y)  Entorno : $(ENV)$(_X)\n  Accion  : build-templates\n\n"; \
	fi; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-$(ENV).sh && cd $(TEMPLATES_DIR) && terraform apply -var-file=$(ENV).tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

destroy-templates:
	@_ok=yes; \
	if [ "$(ENV)" = "pro" ]; then \
		$(call _pro_box); \
		printf "  $(_R)Accion  : destroy-templates$(_X)\n\n"; \
	else \
		printf "\n$(_Y)  Entorno : $(ENV)$(_X)\n  Accion  : destroy-templates\n\n"; \
	fi; \
	read -p "  Confirmar? [y/N] " _ans; \
	[ "$$_ans" = "y" ] || [ "$$_ans" = "Y" ] || _ok=no; \
	if [ "$$_ok" = "yes" ]; then \
		source scripts/env-$(ENV).sh && cd $(TEMPLATES_DIR) && terraform destroy -var-file=$(ENV).tfvars; \
	else \
		printf "  Cancelado.\n\n"; \
	fi

# ── Formato ────────────────────────────────────────────────────────

fmt:
	terraform fmt -recursive

# ── Git ────────────────────────────────────────────────────────────

commit:
	@FORCE="0" bash ./scripts/commit.sh "$(m)"

fcommit:
	@FORCE="1" bash ./scripts/commit.sh

push:
	@FORCE="0" bash ./scripts/push.sh

fpush:
	@FORCE="1" bash ./scripts/push.sh

switch:
	@bash ./scripts/switch.sh
