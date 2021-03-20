#!/bin/bash
#
# backup-mysql.sh 1.0.5
#
# Dumps all databases to seperate files.
# All files are created in a folder named by the current date.
# Folders exceeding the defined hold time are purged automatically.
#
# (c)2015-2019 Harald Schneider
#

# Setup.start
#
HOLD_DAYS=7
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/srv/festivals-database/backups"
CREDENTIALS_FILE="/usr/local/festivals-database/mysql.conf"

# Fetch mysql tool path
#
MYSQL_CMD=$(which mysql)
MYSQL_DMP=$(which mysqldump)
MYSQL_CHECK=$(which mysqlcheck)

#
# Setup.end
# Check and auto-repair all databases first
#
echo
echo "Checking all databases - this can take a while ..."
$MYSQL_CHECK --defaults-extra-file=$CREDENTIALS_FILE --auto-repair --all-databases

# Backup
#
echo
echo "Starting backup ..."
mkdir -p "$BACKUP_DIR/$TIMESTAMP"
databases=`$MYSQL_CMD --defaults-extra-file=$CREDENTIALS_FILE -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

for db in $databases; do
  echo "Dumping $db ..."
  $MYSQL_DMP --force --opt --defaults-extra-file=$CREDENTIALS_FILE --databases "$db" | gzip > "$BACKUP_DIR/$TIMESTAMP/$db.gz"
done
echo
echo "Cleaning up ..."
find $BACKUP_DIR -type d -mtime +$HOLD_DAYS -maxdepth 1 -mindepth 1 -exec rm -rf {} \;
echo "-- DONE!"
