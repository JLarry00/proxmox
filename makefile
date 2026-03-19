all: help

help:
	@echo "Uso del Makefile:"
	@echo "  make commit m=\"mensaje\"          - Agrega y commitea los cambios con el mensaje indicado."
	@echo "  make push                        - Commitea (si hay cambios), pregunta mensaje al usuario, y pushea."
	@echo "  make push force                  - Commitea con mensaje predeterminado y pushea."
	@echo "  make help                        - Muestra esta ayuda."

.PHONY: commit push help

commit:
	@bash ./scripts/commit.sh "$(m)"

push:
	@FORCE="$(force)" bash ./scripts/push.sh

push-force: 
	$(MAKE) push force=1