all: help

help:
	@echo "Uso del Makefile:"
	@echo "  make commit m=\"mensaje\"          - Agrega y commitea los cambios con el mensaje indicado."
	@echo "  make push                        - Commitea (si hay cambios), pregunta mensaje al usuario, y pushea."
	@echo "  make push force                  - Commitea con mensaje predeterminado y pushea."
	@echo "  make help                        - Muestra esta ayuda."

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
	@if [ "$(force)" = "1" ]; then \
		MENSAJE="makefile: add - commit - push"; \
	else \
		if ! git diff-index --quiet HEAD --; then \
			read -p "Ingrese un mensaje para el commit: " MENSAJE; \
			if [ -z "$$MENSAJE" ]; then \
				echo "⚠️  El mensaje de commit no puede estar vacío. Abortando..."; \
				exit 1; \
			fi; \
		else \
			MENSAJE=""; \
		fi; \
	fi; \
	if ! git diff-index --quiet HEAD --; then \
		git add .; \
		git commit -m "$$MENSAJE"; \
		echo ""; \
		echo "=================================================="; \
		echo "🔄  Cambios detectados. Comiteados con mensaje: $$MENSAJE."; \
		echo "=================================================="; \
		echo ""; \
	else \
		echo ""; \
		echo "------------------------------------------"; \
		echo "✅  No hay cambios para commitear."; \
		echo "------------------------------------------"; \
	fi; \
	echo ""; \
	echo "=========================================="; \
	echo "⬆️  Pusheando cambios al repositorio..."; \
	echo "=========================================="; \
	echo ""; \
	git push; \
	echo ""; \
	echo "=========================================="; \
	echo "✅  Cambios pusheados al repositorio."; \
	echo "=========================================="; \
	echo "";

push-force: 
	$(MAKE) push force=1