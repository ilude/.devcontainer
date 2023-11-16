# include .env if present
MAKEFILE_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
PARENT_DIR := $(realpath $(MAKEFILE_DIR)../)
ENV_FILE := $(realpath $(PARENT_DIR)/.env) 
USER := $(or $(USER),$(shell whoami))
DATE := $(shell TZ=America/Los_Angeles date '+%Y-%m-%d-%H.%M.%S')
export GIT_USER := $(shell echo "$(GIT_USER)" | tr A-Z a-z)

ifneq (,$(wildcard $(ENV_FILE)))
	include $(ENV_FILE)
	export
endif

DOTFILES_URL := $(or $(DOTFILES_URL),https://github.com/ilude/dotfiles.git)

.PHONY: dotfiles update-dotfiles echo ownership setup ssh
setup: ownership $(ENV_FILE) ssh dotfiles
	git config -l | grep 'safe.directory=*' || git config --global --add safe.directory '*'
	@echo "Makefile Completed..."

ownership:	
	sudo chown -R $(USER):$(USER) $(PARENT_DIR)

echo:
	@echo ENV_FILE: $(ENV_FILE)
	@echo PARENT_DIR: $(PARENT_DIR)
	@echo MAKEFILE_DIR: $(MAKEFILE_DIR)
	@echo VSCODE_DIR: $(VSCODE_DIR)
	@echo VSCODE_SETTINGS_FILE: $(VSCODE_SETTINGS_FILE)
	@echo DOTFILES_URL: $(DOTFILES_URL)

$(ENV_FILE):
	@echo "Creating empty $@ file..."
	touch $@

ssh:
	@echo "Setting up ~/.ssh..."
	@sudo chown -R $(USER):$(USER) ~/.ssh
	@chmod 700 ~/.ssh
	@chmod 600 ~/.ssh/*
	@echo "Setting up ssh-agent..."
	@ssh-add
	@eval `ssh-agent`

reload-dotfiles:
	symlinks -v ~ | grep .dotfiles | awk '{print $$2}' | xargs rm
	rm -rf .dotfiles
	make dotfiles

dotfiles: ~/.dotfiles/.git
	@echo "Preparing to load/update ~/.dotfiles from $(DOTFILES_URL)..."
ifneq (,$(DOTFILES_URL))
	@echo "Pulling latest ~/.dotfiles changes..."
	@cd ~/.dotfiles/ && git pull --quiet --rebase --autostash
	@echo "Running ~/.dotfiles/install..."
	~/.dotfiles/install
endif

~/.dotfiles/.git: 
ifneq (,$(DOTFILES_URL))
	git clone $(DOTFILES_URL) ~/.dotfiles --recurse-submodules
else
	@echo "DOTFILES_URL has not been set!"
endif