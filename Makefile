SHELL=/bin/bash
DOTENV=.env
DEFSITE=web/sites/default
SETTINGS=$(DEFSITE)/settings.php
LOCALSETTINGS=$(DEFSITE)/settings.local.php
DBIMPORTED=initial/dbimported
DUMPGZ=initial/dump.sql.gz
SYM_CLI = ./symfony
SYM_CLI_VERSION = 4.27.5
SYM_CLI_ARCH = amd64
SYM_CLI_URL = https://github.com/symfony/cli/releases/download/v$(SYM_CLI_VERSION)/symfony_linux_$(SYM_CLI_ARCH).gz

.PHONY: all
all: $(SETTINGS) $(LOCALSETTINGS)

$(SYM_CLI):
	curl -L $(SYM_CLI_URL) | gzip -d > $@
	chmod +x $@

$(DOTENV):
	test -f $@ || echo "You need a $(DOTENV). Use env.sample as a model" && exit 1

web: composer.lock
	composer install
	touch $@

$(SETTINGS): initial/settings.php | web
	cp initial/settings.php $@

$(LOCALSETTINGS): initial/settings.local.php $(DOTENV) | web
	source $(DOTENV) && mkdir -p $(DEFSITE)/files/$$CONFSYNCDIR
	source $(DOTENV) && envsubst '$$DBNAME $$DBUSER $$DBPASS $$DBHOST $$CONFSYNCDIR' < initial/settings.local.php > $@

$(DBIMPORTED): | $(DUMPGZ)
	source $(DOTENV) && mysql -u $$DBUSER -h $$DBHOST --password=$$DBPASS -e "create database if not exists $$DBNAME"
	source $(DOTENV) && gzip -dc $(DUMPGZ) | mysql -u $$DBUSER -h $$DBHOST --password=$$DBPASS -U $$DBNAME
	touch $@

.PHONY: run
run: all $(SYM_CLI) $(DBIMPORTED)
	$(SYM_CLI) server:start
