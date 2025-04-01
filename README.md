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

- [Golang](https://go.dev/) Version 1.24.1+
- [Visual Studio Code](https://code.visualstudio.com/download) 1.98.2+
  - Plugin recommendations are managed via [workspace recommendations](https://code.visualstudio.com/docs/editor/extension-marketplace#_recommended-extensions).
- [Bash script](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) friendly environment
- [MySQL Community Edition](https://www.mysql.com/de/products/community/) Version 9+

## Deployment

The Go binaries are able to run without system dependencies so there are not many requirements for the system to run the festivals-database-node binary and most systems can run a mysql server,
just follow the [**deployment guide**](./operation/DEPLOYMENT.md) for deploying it inside a virtual machine or the [**local deployment guide**](./operation/local/README.md) for running it on your macOS developer machine.

## Engage

I welcome every contribution, whether it is a pull request or a fixed typo. The best place to discuss questions and suggestions regarding the database is the [issues](https://github.com/festivals-app/festivals-database/issues/) section. More general information and a good starting point if you want to get involved is the [festival-documentation](https://github.com/Festivals-App/festivals-documentation) repository.

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/festivals-app/festivals-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/festivals-app/festivals-documentation/question.svg?style=flat-square"></a> </a>   |
| **Other Requests**    | <a href="mailto:simon@festivalsapp.org" title="Email me"><img src="https://img.shields.io/badge/email-Simon-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

### Licensing

Copyright (c) 2017-2025 Simon Gaus. Licensed under the [**GNU Lesser General Public License v3.0**](./LICENSE)
