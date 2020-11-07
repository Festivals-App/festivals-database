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
  <a href="#usage">Usage</a> •
  <a href="#deployment">Deployment</a> •
  <a href="#engage">Engage</a> •
  <a href="#licensing">Licensing</a>
</p>

This is the repository of the MySQL database used by the [festivals-server](https://github.com/festivals-app/festivals-server).

## Development

TBI

## Usage

The database `festivals_api_database` has two users who can access it from a remote machine:
  + `festivals.api.reader` This user is only able to read from the database.
  + `festivals.api.writer` This user can read and write to the database.

The port is the default MySQL port `3306`

### Documentation

The full documentation for the Festivals App is in the [festivals-documentation](https://github.com/festivals-app/festivals-documentation) repository. The documentation repository contains technical documents, architecture information, UI/UX specifications, and whitepapers related to this implementation.

## Deployment

The project offers scripts to deploy the database on CentOS, macOS and Ubuntu.

### CentOS 8

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

### Docker

```bash
TBA
```

### macOS

```bash
TBA
```

## Engage

TBA

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square"></a> </a>   |
| **Concept Feedback**    | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="Open Concept Feedback"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/architecture.svg?style=flat-square"></a>  |
| **Other Requests**    | <a href="mailto:phisto05@gmail.com" title="Email Festivals Team"><img src="https://img.shields.io/badge/email-Festivals%20team-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

## Licensing

Copyright (c) 2020 Simon Gaus.

Licensed under the **GNU Lesser General Public License v3.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.html.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
