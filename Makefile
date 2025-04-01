# Makefile for festivals-database-node

VERSION=development
DATE=$(shell date +"%d-%m-%Y-%H-%M")
REF=refs/tags/development
DEV_PATH_MAC=$(shell echo ~/Library/Containers/org.festivalsapp.project)
export

build:
	go build -v -ldflags="-X 'github.com/Festivals-App/festivals-database/server/status.ServerVersion=$(VERSION)' -X 'github.com/Festivals-App/festivals-database/server/status.BuildTime=$(DATE)' -X 'github.com/Festivals-App/festivals-database/server/status.GitRef=$(REF)'" -o festivals-database-node main.go

install:
	mkdir -p $(DEV_PATH_MAC)/usr/local/bin
	mkdir -p $(DEV_PATH_MAC)/etc
	mkdir -p $(DEV_PATH_MAC)/var/log
	mkdir -p $(DEV_PATH_MAC)/usr/local/festivals-database-node

	cp operation/local/ca.crt  $(DEV_PATH_MAC)/usr/local/festivals-database-node/ca.crt
	cp operation/local/server.crt  $(DEV_PATH_MAC)/usr/local/festivals-database-node/server.crt
	cp operation/local/server.key  $(DEV_PATH_MAC)/usr/local/festivals-database-node/server.key
	cp operation/local/ca.pem  $(DEV_PATH_MAC)/usr/local/festivals-database-node/ca.pem
	cp operation/local/database.pem  $(DEV_PATH_MAC)/usr/local/festivals-database-node/database.pem
	cp operation/local/databasekey.pem  $(DEV_PATH_MAC)/usr/local/festivals-database-node/databasekey.pem
	cp festivals-database-node $(DEV_PATH_MAC)/usr/local/bin/festivals-database-node
	chmod +x $(DEV_PATH_MAC)/usr/local/bin/festivals-database-node
	cp operation/local/config_template_dev.toml $(DEV_PATH_MAC)/etc/festivals-database-node.conf

run:
	./festivals-database-node --container="$(DEV_PATH_MAC)"

run-env:
	$(DEV_PATH_MAC)/usr/local/bin/festivals-identity-server --container="$(DEV_PATH_MAC)" &
	sleep 1
	$(DEV_PATH_MAC)/usr/local/bin/festivals-gateway --container="$(DEV_PATH_MAC)" &

stop-env:
	killall festivals-gateway
	killall festivals-identity-server

clean:
	rm -r festivals-database-node