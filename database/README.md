# Database deployment

The database is used by the [festivals-server](https://github.com/festivals-app/festivals-server) for persistently storing festival data.

## Local development macOS

First you need to [install](https://www.novicedev.com/blog/how-install-mysql-macos-homebrew) and configure mysql on your development machine.

```bash
brew install mysql
mysql_secure_installation
```

Staring and logging into mysql

```bash
brew services start mysql
mysql -uroot -p
```

Logout and stopping mysql

```bash
exit;
brew services stop mysql
```

## Server deployment

The [install script](../operation/install.sh) will install and secure the database.

### MYSQL cheatsheet

```mysql
SHOW DATABASES;
USE database;
SELECT * FROM table
```
