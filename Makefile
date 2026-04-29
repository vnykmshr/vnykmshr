.PHONY: help setup serve check clean

PORT ?= 8000

help: ## show targets
	@grep -E '^[a-z].*:.*##' Makefile | sed 's/:.*##/  —/' | sort

setup: ## configure git hooks
	git config core.hooksPath .githooks
	@echo "done"

serve: ## serve site locally
	@echo "http://localhost:$(PORT)"
	@python3 -m http.server $(PORT) -d docs

check: ## validate html and check hygiene
	@echo "checking docs/"
	@find docs -name '*.html' | while read -r f; do \
		echo "  $$f"; \
		grep -qn '<!DOCTYPE html>' "$$f" || echo "    missing doctype"; \
		grep -qn '<html lang=' "$$f" || echo "    missing lang attribute"; \
		grep -qn 'charset' "$$f" || echo "    missing charset"; \
		grep -qn 'viewport' "$$f" || echo "    missing viewport"; \
	done
	@echo "checking for external requests (src=, link href=, @import)"
	@if find docs -name '*.html' -exec grep -EHn '(src|link.*href)=.https?://' {} + | grep -v 'data:image' | grep -v 'rel="canonical"' | grep -v 'rel="icon"' | grep .; then \
		echo "  ^ unexpected external requests in html"; \
	elif grep -rn '@import.*https\?://' docs/assets/css/*.css 2>/dev/null; then \
		echo "  ^ unexpected css import"; \
	else \
		echo "  none found"; \
	fi
	@echo "file sizes"
	@find docs -name '*.html' -o -name '*.css' -o -name '*.js' | xargs wc -c 2>/dev/null | sort -n
	@echo "done"

clean: ## remove os artifacts
	find . -name '.DS_Store' -delete
	find . -name '*~' -delete
