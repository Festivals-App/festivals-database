<p align="center">
   <a href="https://github.com/Festivals-App/festivals-database/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/Festivals-App/festivals-database?style=flat"></a>
   <a href="https://github.com/festivals-app/festivals-database/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/festivals-app/festivals-database?style=flat"></a>
   <a href="./LICENSE" title="License"><img src="https://img.shields.io/github/license/festivals-app/festivals-database.svg"></a>
</p>

<h1 align="center">
    <br/><br/>
    Festivals App Database
    <br/><br/>
</h1>

This is the project repository of the MySQL database used by the [festivals-server](https://github.com/festivals-app/festivals-server) for persistently storing festival data
and a lightweight go sidecar app, called festivals-database-node. The festivals-database-node will register with the festivals-gateway discovery service and exposes other
functions including backing up the database.

![Figure 1: Architecture Overview Highlighted](https://github.com/Festivals-App/festivals-documentation/blob/main/images/architecture/architecture_overview_database.svg "Figure 1: Architecture Overview Highlighted")

<hr/>
<p align="center">
    <a href="#development">Development</a> •
    <a href="#deployment">Deployment</a> •
    <a href="#usage">Usage</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#engage">Engage</a>
</p>
<hr/>

## Development

The database development is currently a little bit under-organized as at the moment there are really just database scripts storing the schema and the test data.
Beside that there are bash scripts to install, backup, restore and uninstall the database but it all depends on manually running the script rather than having a
build or test procedure. To test whether the database is correct i'm currently relying on downstream tests of the [webserver](https://github.com/Festivals-App/festivals-server)
or [API framework](https://github.com/Festivals-App/festivals-api-ios) and on the ability to rollback the database to a backup known to work.

### Requirements

- [Bash script](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) friendly environment
- [Visual Studio Code](https://code.visualstudio.com/download) 1.84.2+
  - Plugin recommendations are managed via [workspace recommendations](https://code.visualstudio.com/docs/editor/extension-marketplace#_recommended-extensions).
- [MySQL Community Edition](https://www.mysql.com/de/products/community/) Version 8+

## Deployment

All of the deployment scripts require at least Ubuntu 20 LTS as the operating system, so you have to do the [general VM setup](https://github.com/Festivals-App/festivals-documentation/tree/master/deployment/general-vm-setup) first and than use the install script to get the database and database-node running.

The project folders are located at `/usr/local/festivals-database` and `/usr/local/festivals-database-node`.
The backup folder is located at `/srv/festivals-database/backups`.

The Go binaries are able to run without system dependencies so there are not many requirements for the system to run the festivals-database-node binary.
The config file needs to be placed at `/etc/festivals-database-node.conf` or the template config file needs to be present in the directory the binary runs in.

You need to provide certificates in the right format and location:

- The default path to the root CA certificate is          `/usr/local/festivals-database-node/ca.crt`
- The default path to the server certificate is           `/usr/local/festivals-database-node/server.crt`
- The default path to the corresponding key is            `/usr/local/festivals-database-node/server.key`

The database alswo needs certificates in the right format and location:

- The default path to the root CA certificate is          `/var/lib/mysql/ca.pem`
- The default path to the database certificate is         `/var/lib/mysql/database.pem`
- The default path to the corresponding key is            `/var/lib/mysql/database-key.pem`

### The database

You need to convert the root and server certificate and server key to PEM for MYSQL being able to use the files:

```bash
openssl x509 -in mycert.crt -out mycert.pem -outform PEM
openssl rsa -in my.key -text > mykey.pem
```

#### [Installing](https://github.com/Festivals-App/festivals-database/blob/main/operation/install_database.sh) a new instance of the database

```bash
curl -o install_database.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/install_database.sh
chmod +x install_database.sh
sudo ./install_database.sh <mysql_root_pw> <mysql_backup_pw> <read_only_pw> <read_write_pw>
```

Configure ssl certificates, see [festivals-pki repository](https://github.com/Festivals-App/festivals-pki) on how to obtain them.
If your system enforces AppArmor profiles, the certificates must be located in the mysql data dir at /var/lib/mysql

```bash
sudo nano /etc/mysql/mysql.conf.d/festivals-database.cnf
// configure bind-address=<private-ip>
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

#### [Restoring](https://github.com/Festivals-App/festivals-database/blob/main/operation/restore_database.sh) a backup created by the backup script

```bash
curl -o restore_database.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/restore_database.sh
chmod +x restore_database.sh
sudo ./restore_database.sh <url_to_zipped_backup>
```

#### Setup test database

```bash
curl -L -o insert_testdata.sql https://raw.githubusercontent.com/Festivals-App/festivals-database/main/database_scripts/insert_testdata.sql
sudo mysql -uroot -p -e "source ./insert_testdata.sql"
```

#### MySQL CheatSheet

```mysql
brew services restart mysql

> SHOW DATABASES; 
> USE festivals_api_database;
> SHOW TABLES;
> SELECT * FROM ;
> EXIT;
```

#### The database node

#### [Installing](https://github.com/Festivals-App/festivals-database/blob/main/operation/install_node.sh) the database-node

```bash
curl -o install_node.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/install_node.sh
chmod +x install_node.sh
sudo ./install_node.sh
```

## Usage

The database `festivals_api_database` has two users who can access it from a remote machine:

- `festivals.api.reader` This user is only able to read from the database.
- `festivals.api.writer` This user can read and write to the database.

The port is the default MySQL port `3306`

# Documentation & Architecture

The FestivalsApp database is tightly coupled with the [festivals-server](https://github.com/Festivals-App/festivals-server) which provides the implementation of the FestivalsAPI as the database functions as its persistent storage. To find out more about architecture and technical information see the [ARCHITECTURE](./ARCHITECTURE.md) document.

The general documentation for the Festivals App is in the [festivals-documentation](https://github.com/festivals-app/festivals-documentation) repository.
The documentation repository contains architecture information, general deployment documentation, templates and other helpful documents.

## Engage

I welcome every contribution, whether it is a pull request or a fixed typo. The best place to discuss questions and suggestions regarding the database is the [issues](https://github.com/festivals-app/festivals-database/issues/) section. More general information and a good starting point if you want to get involved is the [festival-documentation](https://github.com/Festivals-App/festivals-documentation) repository.

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square"></a> </a>   |
| **Other Requests**    | <a href="mailto:simon.cay.gaus@gmail.com" title="Email me"><img src="https://img.shields.io/badge/email-Simon-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

### Licensing

Copyright (c) 2017-2024 Simon Gaus. Licensed under the [**GNU Lesser General Public License v3.0**](./LICENSE)
