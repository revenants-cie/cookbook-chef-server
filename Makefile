.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
    match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
    if match:
        target, help = match.groups()
        print("%-40s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

# help: install-hooks
.PHONY: help
help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < Makefile

.PHONY: install-hooks update-secrets
update-secrets:  ## Update secrets in .env.tar.enc
	tar cf .env.tar .env
	travis encrypt-file .env.tar --add --com
	rm .env.tar

.PHONY: install-hooks
install-hooks:  ## Install repo hooks
	@echo "Checking and installing hooks"
	@test -d .git/hooks || (echo "Looks like you are not in a Git repo" ; exit 1)
	@test -L .git/hooks/pre-commit || ln -fs ../../hooks/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit

.PHONY: lint
lint: ## Run code style checks
	foodcritic .

.PHONY: test
test: ## Run Kitchen test on supported platforms
	kitchen test

.PHONY: bootstrap
bootstrap: ## bootstrap the development environment
	pip install -U "pip ~= 20.1"
	pip install -U "setuptools ~= 47.2"
	pip install -r requirements_dev.txt

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

.PHONY: docs
docs: ## generate Sphinx HTML documentation, including API docs
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html
