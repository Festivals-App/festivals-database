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

![Figure 1: Architecture Overview Highlighted](https://github.com/Festivals-App/festivals-documentation/blob/main/images/architecture/overview_database.png "Figure 1: Architecture Overview Highlighted")

<hr/>
<p align="center">
    <a href="#development">Development</a> •
    <a href="#deployment">Deployment</a> • 
    <a href="#usage">Usage</a> • 
    <a href="#architecture">Architecture</a> •
    <a href="#engage">Engage</a> •
    <a href="#licensing">Licensing</a>
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
    * Plugin recommendations are managed via [workspace recommendations](https://code.visualstudio.com/docs/editor/extension-marketplace#_recommended-extensions).
- [MySQL Community Edition](https://www.mysql.com/de/products/community/) Version 8+ 

### Setup

1. Install and setup [Visual Studio Code](https://code.visualstudio.com/download) 1.84.2+ or higher

## Deployment

All of the deployment scripts require Ubuntu 20 LTS as the operating system, so you have to do the [general VM setup](https://github.com/Festivals-App/festivals-documentation/tree/master/deployment/general-vm-setup) first and than use the install script to get the database and database-node running.

The project folders are located at `/usr/local/festivals-database` and `/usr/local/festivals-database-node`.

The backup folder is located at `/srv/festivals-database/backups`.

### The database

You need to convert the root and server certificate and server key to PEM for MYSQL being able to use the files
```
openssl x509 -in mycert.crt -out mycert.pem -outform PEM
openssl rsa -in my.key -text > mykey.pem
```



#### [Installing](https://github.com/Festivals-App/festivals-database/blob/main/operation/install_database.sh) a new instance of the database. 
```bash
curl -o install_database.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/install_database.sh
chmod +x install_database.sh
sudo ./install_database.sh <mysql_root_pw> <mysql_backup_pw> <read_only_pw> <read_write_pw>
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf          // edit bind-address=<private-ip>
sudo nano       // set certificate values
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
> SHOW DATABASES;
> USE festivals_api_database;
> SHOW TABLES;
> SELECT * FROM ;
> EXIT;
```

### The database node

#### [Installing](https://github.com/Festivals-App/festivals-database/blob/main/operation/install_node.sh) the database-node. 
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

# Engage & Feedback

I welcome every contribution, whether it is a pull request or a fixed typo. The best place to discuss questions and suggestions regarding the database is the [issues](https://github.com/festivals-app/festivals-database/issues/) section. More general information and a good starting point if you want to get involved is the [festival-documentation](https://github.com/Festivals-App/festivals-documentation) repository.

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square"></a> </a>   |
| **Other Requests**    | <a href="mailto:simon.cay.gaus@gmail.com" title="Email me"><img src="https://img.shields.io/badge/email-Simon-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

## Licensing

Copyright (c) 2017-2023 Simon Gaus.

Licensed under the **GNU Lesser General Public License v3.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.html.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
