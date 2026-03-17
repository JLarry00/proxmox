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
		make commit m="makefile: add commit and push"; \
		echo ""; \
		echo "=================================================="; \
		echo "🔄  Cambios detectados. Comiteando y pusheando..."; \
		echo "=================================================="; \
		echo ""; \
	else \
		echo ""; \
		echo "------------------------------------------"; \
		echo "✅  No hay cambios para commitear."; \
		echo "------------------------------------------"; \
		echo ""; \
	fi
	echo "==========================================";
	echo "⬆️  Pusheando cambios al repositorio...";
	echo "==========================================";
	git push