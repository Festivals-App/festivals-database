# Festivals App Database

[![](https://img.shields.io/github/last-commit/Festivals-App/festivals-database?style=flat)](https://github.com/Festivals-App/festivals-database/commits/ "Last Commit") [![](https://img.shields.io/github/issues/festivals-app/festivals-database?style=flat)](https://github.com/festivals-app/festivals-database/issues "Open Issues") [![](https://img.shields.io/github/license/festivals-app/festivals-database.svg)](./LICENSE "License")

[Development](#development) • [Usage](#usage) • [Deployment](#deployment) • [Engage](#engage) • [Licensing](#licensing)

This is the repository of the MySQL database used by the [festivals-server](https://github.com/festivals-app/festivals-server).

## Development

### Setup

I use the open source editor [Atom](https://atom.io/) for development. You can use every text editor you like for development but for the sake of code uniformity i would encourage you to also use the Atom editor.

1. Install Atom 1.55.0 or higher
2. Install the following Atom packages:

  - language-sql-mysql
  - tidy-markdown
  - pp-markdown (_optional_)

## Usage

The database `festivals_api_database` has two users who can access it from a remote machine:

- `festivals.api.reader` This user is only able to read from the database.
- `festivals.api.writer` This user can read and write to the database.

The port is the default MySQL port `3306`

## Deployment

The install, update and uninstall scripts should work with any system that uses _systemd_, _firewalld_ or _ufw_ and it optionally supports _SELinux_. Additionally the scripts will somewhat work under macOS but won't configure the firewall or launch service.

```bash
curl -o install.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/install.sh
chmod +x install.sh
sudo ./install.sh <root password>  <read_only password> <read_write password>
```

Import test data if you want to use the database for testing:

```bash
curl -L -o create_database.sql https://raw.githubusercontent.com/Festivals-App/festivals-database/main/database_scripts/create_database.sql
sudo mysql -uroot -p<password> -e "source ./create_database.sql"
```

Uninstalling

```bash
curl -o uninstall.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/uninstall.sh
chmod +x uninstall.sh
sudo ./uninstall.sh
```

### Docker

```bash
TBA
```

### Documentation

The full documentation for the Festivals App is in the [festivals-documentation](https://github.com/festivals-app/festivals-documentation) repository. The documentation repository contains technical documents, architecture information, UI/UX specifications, and whitepapers related to this implementation.

## Engage

TBA

The following channels are available for discussions, feedback, and support requests:

Type                   | Channel
---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
**General Discussion** | [![](https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square)](https://github.com/festivals-app/festivals-documentation/issues/new/choose "General Discussion")
**Concept Feedback**   | [![](https://img.shields.io/github/issues/festivals-app/festivals-documentation/architecture.svg?style=flat-square)](https://github.com/festivals-app/festivals-documentation/issues/new/choose "Open Concept Feedback")
**Other Requests**     | [![](https://img.shields.io/badge/email-Festivals%20team-green?logo=mail.ru&style=flat-square&logoColor=white)](mailto:phisto05@gmail.com "Email Festivals Team")

## Licensing

Copyright (c) 2020 Simon Gaus.

Licensed under the **GNU Lesser General Public License v3.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at <https://www.gnu.org/licenses/lgpl-3.0.html>.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
