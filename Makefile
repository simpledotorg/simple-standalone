hosts = sample/playground
branch = master
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

.PHONY: help init all deploy ship update-ssh-keys update-app-config restart-passenger restart-sidekiq
# HELP sourced from https://gist.github.com/prwhite/8168133

# Add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUNC = \
    %help; \
    while(<>) { \
        if(/^([a-z0-9_-]+):.*\#\#(?:@(\w+))?\s(.*)$$/) { \
            push(@{$$help{$$2}}, [$$1, $$3]); \
        } \
    }; \
    print "usage: make [target] hosts=<sample/playground>\n\n"; \
    for ( sort keys %help ) { \
        print "$$_:\n"; \
        printf("  %-20s %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
        print "\n"; \
    }

help: ##@Miscellaneous Show this help.
	@perl -e '$(HELP_FUNC)' $(MAKEFILE_LIST)

init: ##@Setup Install ansible plugins and dependencies
	ansible-galaxy install -r requirements.yml
	ansible-galaxy collection install -r requirements.yml -p ~/.ansible/collections
	pip install jmespath

all: ##@Setup Install simple-server on hosts. Runs the all.yml playbook
	ansible-playbook $@.yml -i hosts/$(hosts)

debug: ##@Debug Fetch debug information from hosts
	ansible-playbook debug.yml -i hosts/$(hosts)

decrypt: ##@Vault Decrypt vault secrets for a deployment
	ansible-vault decrypt group_vars/$(hosts)/vault.yml --output group_vars/$(hosts)/vault.yml.decrypted

deploy: ship restart ##@Deploy Deploy simple-server/master on hosts.

edit-vault: ##@Vault Edit vault secrets for a deployment
	ansible-vault edit group_vars/$(hosts)/vault.yml

encrypt: ##@Vault Encrypt vault secrets for a deployment
	ansible-vault encrypt group_vars/$(hosts)/vault.yml.decrypted --output group_vars/$(hosts)/vault.yml --encrypt-vault-id $(hosts)

ship: ##@Deploy Ship simple-server/master to hosts. Runs an ansitrano deploy
	ansible-playbook deploy.yml -i hosts/$(hosts) --extra-vars="ansistrano_git_branch=$(branch)"

update-ssh-keys: ##@Utilities Update ssh keys on boxes. Add keys to `roles/ssh/` under the appropriate environment
	ansible-playbook setup.yml -i hosts/$(hosts) --tags ssh

update-app-config: ##@Utilities Update app config .env file
	ansible-playbook deploy.yml -i hosts/$(hosts) --tags update-app-config

update-ssl-certs: ##@Utilities Update the SSL certs. Add the appropriate certs under the encrypted ssl-vault.yml
	ansible-playbook load_balancing.yml -i hosts/$(hosts) --tags load_balancing

restart: restart-passenger restart-sidekiq ##@Utilities Restart Simple server

restart-passenger: ##@Utilities Restart passenger
	ansible-playbook setup.yml -i hosts/$(hosts) -l webservers --tags restart-passenger

restart-sidekiq: ##@Utilities Restart sidekiq
	ansible-playbook deploy.yml -i hosts/$(hosts) -l sidekiq --tags restart-sidekiq
