# Database deployment

The database is used by the [festivals-server](https://github.com/festivals-app/festivals-server) for persistently storing festival data.

## Server deployment

The [install script](../operation/install.sh) will install and secure the database.

### MYSQL cheatsheet

```bash
brew services start mysql
brew services restart mysql
brew services stop mysql
```

```mysql
SHOW DATABASES;
USE database;
SHOW TABLES;
SELECT * FROM table
```
