# Common tasks. Run "make deps" once, then "make lint", "make check", "make apply".

VENV            ?= .venv
PIP             := $(VENV)/bin/pip
PY              := $(VENV)/bin/python
COLLECTIONS_DIR ?= .collections
INVENTORY       ?= inventory/example/hosts.yml
PLAYBOOK        ?= playbooks/site.yml
LIMIT           ?= all
TAGS            ?= all
MOLECULE_DISTRO ?= ubuntu2404

export ANSIBLE_COLLECTIONS_PATH := $(CURDIR)/$(COLLECTIONS_DIR)

.PHONY: help deps lint syntax check apply molecule clean

help:
	@echo "deps      create $(VENV), install Python deps and Galaxy collections"
	@echo "lint      yamllint + ansible-lint (production profile)"
	@echo "syntax    ansible-playbook --syntax-check"
	@echo "check     dry run: --check --diff (LIMIT=host TAGS=tag to narrow)"
	@echo "apply     apply the playbook with --diff"
	@echo "molecule  run the molecule scenario (MOLECULE_DISTRO=ubuntu2204|ubuntu2404|debian12)"
	@echo "clean     remove venv, collections and caches"

$(VENV)/bin/activate: requirements.txt
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	touch $(VENV)/bin/activate

deps: $(VENV)/bin/activate
	$(VENV)/bin/ansible-galaxy collection install -r requirements.yml -p $(COLLECTIONS_DIR)

lint: deps
	$(PY) -m yamllint -c .yamllint.yaml --strict .
	$(VENV)/bin/ansible-lint

syntax: deps
	$(VENV)/bin/ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --syntax-check

check: deps
	$(VENV)/bin/ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --check --diff --limit "$(LIMIT)" --tags "$(TAGS)"

apply: deps
	$(VENV)/bin/ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --diff --limit "$(LIMIT)" --tags "$(TAGS)"

molecule: deps
	MOLECULE_DISTRO=$(MOLECULE_DISTRO) $(VENV)/bin/molecule test

clean:
	rm -rf $(VENV) $(COLLECTIONS_DIR) .facts_cache .cache
