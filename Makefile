.PHONY: setup serve check clean

PORT ?= 8000

setup: ## configure git hooks
	git config core.hooksPath .githooks
	@echo "done"

serve: ## serve site locally
	@echo "http://localhost:$(PORT)"
	@python3 -m http.server $(PORT) -d docs

check: ## validate html and check hygiene
	@echo "checking docs/"
	@for f in docs/*.html; do \
		echo "  $$f"; \
		grep -qn '<!DOCTYPE html>' "$$f" || echo "    missing doctype"; \
		grep -qn '<html lang=' "$$f" || echo "    missing lang attribute"; \
		grep -qn 'charset' "$$f" || echo "    missing charset"; \
		grep -qn 'viewport' "$$f" || echo "    missing viewport"; \
	done
	@echo "checking for external requests (src=, link href=, @import)"
	@if grep -rEn '(src|link.*href)=.https?://' docs/*.html | grep -v 'data:image' | grep -v 'rel="canonical"' | grep -v 'rel="icon"'; then \
		echo "  ^ unexpected external requests"; \
	elif grep -rn '@import.*https\?://' docs/*.html; then \
		echo "  ^ unexpected css import"; \
	else \
		echo "  none found"; \
	fi
	@echo "file sizes"
	@wc -c docs/*.html | sort -n
	@echo "done"

clean: ## remove os artifacts
	find . -name '.DS_Store' -delete
	find . -name '*~' -delete

help: ## show targets
	@grep -E '^[a-z].*:.*##' Makefile | sed 's/:.*##/  —/' | sort
