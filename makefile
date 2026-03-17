all: help

help:
	@echo "Uso del Makefile:"
	@echo "  make commit m=\"mensaje\"      - Agrega y commitea los cambios con el mensaje indicado."
	@echo "  make push                    - Commitea (si hay cambios) y pushea al repositorio remoto."
	@echo "  make help                    - Muestra esta ayuda."

.PHONY: commit push help

commit:
	@if [ -z "$(m)" ]; then \
		git add . ; \
		git commit -m "commit"; \
	else \
		git add . ; \
		git commit -m "$(m)"; \
	fi

push:
	@if ! git diff-index --quiet HEAD --; then \
		echo ""; \
		echo "=================================================="; \
		echo "🔄  Cambios detectados. Comiteando y pusheando..."; \
		echo "=================================================="; \
		echo ""; \
		make commit m="makefile: add - commit - push"; \
	else \
		echo ""; \
		echo "------------------------------------------"; \
		echo "✅  No hay cambios para commitear."; \
		echo "------------------------------------------"; \
	fi
	@echo "";
	@echo "==========================================";
	@echo "⬆️  Pusheando cambios al repositorio...";
	@echo "==========================================";
	@echo "";
	@git push
	@echo "";
	@echo "==========================================";
	@echo "✅  Cambios pusheados al repositorio.";
	@echo "==========================================";
	@echo "";