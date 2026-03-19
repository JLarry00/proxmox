all: help

help:
	@echo "Uso del Makefile:"
	@echo "  make commit m=\"mensaje\"          - Agrega y commitea los cambios con el mensaje indicado."
	@echo "  make fcommit                      - Commitea con mensaje predeterminado (sin prompt)."
	@echo "  make push                        - Commitea (si hay cambios), pregunta mensaje al usuario, y pushea."
	@echo "  make fpush                        - Commitea con mensaje predeterminado y pushea."
	@echo "  make help                        - Muestra esta ayuda."

.PHONY: commit push fcommit push fpush help

commit:
	@FORCE="0" bash ./scripts/commit.sh "$(m)"

fcommit:
	@FORCE="1" bash ./scripts/commit.sh

push:
	@FORCE="0" bash ./scripts/push.sh

fpush:
	@FORCE="1" bash ./scripts/push.sh