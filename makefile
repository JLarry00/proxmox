all:
	echo "Run 'make commit m=\"your message\"' to commit, or 'make push' to push."

.PHONY: commit push

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
		make commit m="makefile: add commit and push"; \
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
	@echo "==========================================";
	@echo "✅  Cambios pusheados al repositorio.";
	@echo "==========================================";
	@echo "";