<h1 align="center">
    Festivals App Database
</h1>

<p align="center">
   <a href="https://github.com/Festivals-App/festivals-database/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/Festivals-App/festivals-database?style=flat"></a>
   <a href="https://github.com/festivals-app/festivals-database/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/festivals-app/festivals-database?style=flat"></a>
   <a href="./LICENSE" title="License"><img src="https://img.shields.io/github/license/festivals-app/festivals-database.svg"></a>
</p>

<p align="center">
  <a href="#development">Development</a> •
  <a href="#deployment">Deployment</a> •
  <a href="#usage">Usage</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#engage">Engage</a> •
  <a href="#licensing">Licensing</a>
</p>

This is the project repository of the MySQL database used by the [festivals-server](https://github.com/festivals-app/festivals-server).

## Development

### Setup

I use the open source editor [Atom](https://atom.io/) for development.
You can use every text editor you like but for the sake of code uniformity
i would encourage you to also use the Atom editor.

1. Install Atom 1.55.0 or higher
2. I use the following Atom packages specific in this project:

  - language-sql-mysql
  - pp-markdown

## Deployment

### Server

All of the scripts require Ubuntu 20 LTS as the operating system and that the server has already
been initialised, see the steps to do that [here](https://github.com/Festivals-App/festivals-documentation/tree/master/deployment/general-vm-setup).

```bash
curl -o install.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/install.sh
chmod +x install.sh
sudo ./install.sh <mysql_root_pw> <mysql_backup_pw> <read_only_pw> <read_write_pw>
```

If you want to use the database for testing you can import the test data:

```bash
curl -L -o insert_testdata.sql https://raw.githubusercontent.com/Festivals-App/festivals-database/main/database_scripts/insert_testdata.sql
sudo mysql -uroot -p -e "source ./insert_testdata.sql"
```

Uninstalling the whole configuration:

```bash
curl -o uninstall.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/uninstall.sh
chmod +x uninstall.sh
sudo ./uninstall.sh
```

The only user allowed to login to mysql and use the mysql tools is the default mysql _root_ user.

The project folder is located at `/usr/local/festivals-database`.

The backup folder is located at `/srv/festivals-database/backups`.

### Docker

```bash
TBA
```

## Usage

The database `festivals_api_database` has two users who can access it from a remote machine:

- `festivals.api.reader` This user is only able to read from the database.
- `festivals.api.writer` This user can read and write to the database.

The port is the default MySQL port `3306`

## Documentation

The full documentation for the Festivals App is in the [festivals-documentation](https://github.com/festivals-app/festivals-documentation) repository.
The documentation repository contains technical documents, architecture information,
UI/UX specifications, and whitepapers related to this implementation.

## Engage

TBA

The following channels are available for discussions, feedback, and support requests:

Type                   | Channel
---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
**General Discussion** | [![](https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square)](https://github.com/festivals-app/festivals-documentation/issues/new/choose "General Discussion")
**Concept Feedback**   | [![](https://img.shields.io/github/issues/festivals-app/festivals-documentation/architecture.svg?style=flat-square)](https://github.com/festivals-app/festivals-documentation/issues/new/choose "Open Concept Feedback")
**Other Requests**     | [![](https://img.shields.io/badge/email-Festivals%20team-green?logo=mail.ru&style=flat-square&logoColor=white)](mailto:phisto05@gmail.com "Simon Gaus")

## Licensing

Copyright (c) 2020 Simon Gaus.

Licensed under the **GNU Lesser General Public License v3.0** (the "License");
you may not use this file except in compliance with the License.

You may obtain a copy of the License at <https://www.gnu.org/licenses/lgpl-3.0.html>.

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE)
for the specific language governing permissions and limitations under the License.
