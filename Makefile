.PHONY: help setup serve check check-feed clean

PORT ?= 8000
FEED := $(shell sed -n "s/.*fetch.'\([^']*\)'.*/\1/p" docs/now/index.html)

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

check-feed: ## check the /now feed loads cross-origin (network, not in ci)
	@[ -n "$(FEED)" ] || { echo "no fetch() url found in docs/now/index.html"; exit 1; }
	@echo "checking $(FEED)"
	@h=$$(curl -sS -o /dev/null -D - -H 'Origin: https://vnykmshr.com' "$(FEED)") || exit 1; \
	echo "$$h" | head -1 | grep -q ' 200' || { echo "  expected 200, got: $$(echo "$$h" | head -1)"; echo "  a redirect fails cross-origin -- point the fetch at the final url"; exit 1; }; \
	echo "$$h" | grep -Eiq '^access-control-allow-origin: (\*|https://vnykmshr\.com)' || { echo "  no access-control-allow-origin for vnykmshr.com -- browsers will block the fetch"; exit 1; }
	@curl -sS "$(FEED)" | python3 -c 'import json,sys; i=json.load(sys.stdin)["items"]; assert isinstance(i,list); print(f"  ok, {len(i)} items")' 2>/dev/null \
		|| { echo "  not a json feed with an items list"; exit 1; }

clean: ## remove os artifacts
	find . -name '.DS_Store' -delete
	find . -name '*~' -delete
