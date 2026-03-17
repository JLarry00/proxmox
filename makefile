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
		echo "Changes detected, committing and pushing..."; \
		echo ""; \
	fi
	echo "";
	echo "Pushing changes...";
	echo "";
	git push;