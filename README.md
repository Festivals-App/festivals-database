<p align="center">
   <a href="https://github.com/Festivals-App/festivals-database/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/Festivals-App/festivals-database?style=flat"></a>
   <a href="https://github.com/festivals-app/festivals-database/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/festivals-app/festivals-database?style=flat"></a>
   <a href="./LICENSE" title="License"><img src="https://img.shields.io/github/license/festivals-app/festivals-database.svg"></a>
</p>

<h1 align="center">
    <br/><br/>
    FestivalsApp Database
    <br/><br/>
</h1>

This is the project repository of the MySQL database used by the [festivals-server](https://github.com/festivals-app/festivals-server) for persistently storing festival data
and a lightweight go sidecar app, called festivals-database-node. The festivals-database-node will register with the festivals-gateway discovery service and exposes other
functions including backing up the database.

![Figure 1: Architecture Overview Highlighted](https://github.com/Festivals-App/festivals-documentation/blob/main/images/architecture/export/architecture_overview_database.svg "Figure 1: Architecture Overview Highlighted")

<hr/>
<p align="center">
    <a href="#development">Development</a> •
    <a href="#deployment">Deployment</a> •
    <a href="#engage">Engage</a>
</p>
<hr/>

## Development

The FestivalsApp database is tightly coupled with the [festivals-server](https://github.com/Festivals-App/festivals-server) which provides the implementation of the FestivalsAPI as the database functions as its persistent storage.

The database development is currently a little bit under-organized as at the moment there are really just database scripts storing the schema and the test data.
Beside that there are bash scripts to install, backup, restore and uninstall the database but it all depends on manually running the script rather than having a
build or test procedure. To test whether the database is correct i'm currently relying on downstream tests of the [webserver](https://github.com/Festivals-App/festivals-server)
or [API framework](https://github.com/Festivals-App/festivals-api-ios) and on the ability to rollback the database to a backup known to work.

### Requirements

- [Golang](https://go.dev/) Version 1.23.5+
- [Visual Studio Code](https://code.visualstudio.com/download) 1.97.1+
  - Plugin recommendations are managed via [workspace recommendations](https://code.visualstudio.com/docs/editor/extension-marketplace#_recommended-extensions).
- [Bash script](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) friendly environment
- [MySQL Community Edition](https://www.mysql.com/de/products/community/) Version 8+

## Deployment

All deployment scripts require at least Ubuntu 24.04 LTS, so you must complete the [general VM setup](https://github.com/Festivals-App/festivals-documentation/tree/main/deployment/vm-deployment) first.
Once the setup is done, use the install script to deploy the database and database node.

  > The database project folder is located at `/usr/local/festivals-database`.  
  > The database backup folder is located at `/srv/festivals-database/backups`.  

The Go binaries are able to run without system dependencies so there are not many requirements for the system to run the festivals-database-node binary.
  > The config file is placed at `/etc/festivals-database-node.conf`  
  > The database-node project folder is located at `/usr/local/festivals-database-node`.  

You must ensure that the certificates for the database node are in the correct format and placed in the appropriate location:

  > Root CA certificate     `/usr/local/festivals-database-node/ca.crt`  
  > Server certificate      `/usr/local/festivals-database-node/server.crt`  
  > Server key              `/usr/local/festivals-database-node/server.key`  

The database also needs certificates in the right format and location:

  > Root CA certificate     `/var/lib/mysql/ca.pem`  
  > Database certificate    `/var/lib/mysql/database.pem`  
  > Database key            `/var/lib/mysql/database-key.pem`  
  
You need to convert the root and server certificate and server key to PEM for MYSQL being able to use the files:

```bash
openssl x509 -in mycert.crt -out mycert.pem -outform PEM
openssl rsa -in my.key -text > mykey.pem
```

For instructions on how to manage and create the certificates see the [festivals-pki](https://github.com/Festivals-App/festivals-pki) repository.
If your system enforces AppArmor profiles, the certificates **must** be located in the mysql data dir at /var/lib/mysql

### Installing the database and database-node

The install and update scripts should work with any system that uses *systemd* and *ufw*.
Additionally the scripts will somewhat work under macOS but won't configure the firewall or launch service.

```bash
#Installing the database
curl -o install.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/install.sh
chmod +x install.sh
sudo ./install_database.sh <mysql_root_pw> <mysql_backup_pw> <read_only_pw> <read_write_pw>
```

In order to enable the festivals-server to access the database we need to configure the mysql bind-address:

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# bind-address=<ip-address>
```

### Setup test database

```bash
curl -L -o insert_testdata.sql https://raw.githubusercontent.com/Festivals-App/festivals-database/main/database_scripts/insert_testdata.sql
sudo mysql -uroot -p -e "source ./insert_testdata.sql"
```

### Restoring a backup created by the backup script

```bash
curl -o restore_database.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/restore_database.sh
chmod +x restore_database.sh
sudo ./restore_database.sh <url_to_zipped_backup>
```

### Usage

The database `festivals_api_database` has two users who can access it from a remote machine:

- `festivals.api.reader` This user is only able to read from the database.
- `festivals.api.writer` This user can read and write to the database.

The port is the default MySQL port `3306`

#### MySQL CheatSheet

```mysql
brew services restart mysql

> SHOW DATABASES; 
> USE festivals_api_database;
> SHOW TABLES;
> SELECT * FROM ;
> EXIT;
```

## Engage

I welcome every contribution, whether it is a pull request or a fixed typo. The best place to discuss questions and suggestions regarding the database is the [issues](https://github.com/festivals-app/festivals-database/issues/) section. More general information and a good starting point if you want to get involved is the [festival-documentation](https://github.com/Festivals-App/festivals-documentation) repository.

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square"></a> </a>   |
| **Other Requests**    | <a href="mailto:simon.cay.gaus@gmail.com" title="Email me"><img src="https://img.shields.io/badge/email-Simon-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

### Licensing

Copyright (c) 2017-2025 Simon Gaus. Licensed under the [**GNU Lesser General Public License v3.0**](./LICENSE)
