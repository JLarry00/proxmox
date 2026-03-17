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
	git push