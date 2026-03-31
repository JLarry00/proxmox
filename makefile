ENV ?= dev

DEPLOY_DIR = deploy
TFVARS     = $(DEPLOY_DIR)/$(ENV).tfvars

all: help

help:
	@echo ""
	@echo "Uso del Makefile:"
	@echo "  make init    [ENV=dev|prod]   - terraform init"
	@echo "  make plan    [ENV=dev|prod]   - terraform plan"
	@echo "  make apply   [ENV=dev|prod]   - terraform apply"
	@echo "  make destroy [ENV=dev|prod]   - terraform destroy"
	@echo "  make fmt                      - formatea todos los archivos .tf"
	@echo "  make commit  m=\"mensaje\"      - git add + commit"
	@echo "  make push                     - commit + push"
	@echo "  make switch                   - cambiar de rama git"
	@echo ""
	@echo "  Entorno activo : $(ENV)"
	@echo "  Vars file      : $(TFVARS)"
	@echo ""

.PHONY: init plan apply destroy fmt commit fcommit push fpush switch help

init:
	cd $(DEPLOY_DIR) && terraform init

plan:
	cd $(DEPLOY_DIR) && terraform plan -var-file=$(ENV).tfvars

apply:
	cd $(DEPLOY_DIR) && terraform apply -var-file=$(ENV).tfvars

destroy:
	cd $(DEPLOY_DIR) && terraform destroy -var-file=$(ENV).tfvars

fmt:
	terraform fmt -recursive

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
