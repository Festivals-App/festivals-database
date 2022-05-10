# Makefile for festivals-database-node

VERSION=development
DATE=$(shell date +"%d-%m-%Y-%H-%M")
REF=refs/tags/development
export

build:
	go build -v -ldflags="-X 'github.com/Festivals-App/festivals-database/server/status.ServerVersion=$(VERSION)' -X 'github.com/Festivals-App/festivals-database/server/status.BuildTime=$(DATE)' -X 'github.com/Festivals-App/festivals-database/server/status.GitRef=$(REF)'" -o festivals-database-node main.go

install:
	cp festivals-database-node /usr/local/bin/festivals-database-node
	cp config_template.toml /etc/festivals-database-node.conf
	cp operation/service_template.service /etc/systemd/system/festivals-database-node.service

update:
	systemctl stop festivals-database-node
	cp festivals-database-node /usr/local/bin/festivals-database-node
	systemctl start festivals-database-node

uninstall:
	systemctl stop festivals-database-node
	rm /usr/local/bin/festivals-database-node
	rm /etc/festivals-database-node.conf
	rm /etc/systemd/system/festivals-database-node.service

run:
	./festivals-database-node --debug

stop:
	killall festivals-database-node

clean:
	rm -r festivals-database-node