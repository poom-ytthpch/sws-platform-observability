# Makefile for Kubernetes Platform Observability (platform-observability)
# Automates deployment, validation, and dashboard setups.

ENV ?= development

.PHONY: help install upgrade lint verify validate clean destroy

help:
	@echo "Available commands:"
	@echo "  install   - Deploy all platform observability stacks via helmfile"
	@echo "  upgrade   - Alias for install (runs helmfile apply)"
	@echo "  lint      - Validate YAML and run linter checks"
	@echo "  verify    - Run helmfile template dry-run checks"
	@echo "  validate  - Run all validation and readiness checks"
	@echo "  clean     - Remove temporary files"
	@echo "  destroy   - Tear down all deployed observability stacks"

install:
	@echo "Deploying platform observability stacks (ENV=$(ENV))..."
	helmfile -f helmfile.yaml.gotmpl --environment $(ENV) apply

upgrade: install

lint:
	@echo "Linting configs..."
	yamllint -c .yamllint.yaml .

verify:
	@echo "Verifying helmfile configurations (ENV=$(ENV))..."
	helmfile -f helmfile.yaml.gotmpl --environment $(ENV) template

validate:
	@echo "Executing validation scripts suite..."
	./validation/run-all.sh

clean:
	@echo "Cleaning up local outputs..."
	rm -rf /tmp/rendered-observability.yaml

destroy:
	@echo "Destroying platform observability stacks (ENV=$(ENV))..."
	helmfile -f helmfile.yaml.gotmpl --environment $(ENV) destroy

