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
HOLD_DAYS=30
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/srv/festivals-database/backups"
CREDENTIALS_FILE="/usr/local/festivals-database/mysql.conf"

#
# Setup.end
# Check and auto-repair all databases first
#
echo
echo "Checking all databases - this can take a while ..."
mysqlcheck --defaults-extra-file=$CREDENTIALS_FILE --auto-repair --all-databases

# Backup
#
echo
echo "Starting backup ..."
mkdir -p "$BACKUP_DIR/$TIMESTAMP"
mysqldump --defaults-extra-file=$CREDENTIALS_FILE --force --opt --no-tablespaces --databases 'festivals_api_database' | gzip > "$BACKUP_DIR/$TIMESTAMP/$db-$(date "+%F-%H-%M-%S").gz"
echo
echo "Cleaning up ..."
find $BACKUP_DIR -type d -mtime +$HOLD_DAYS -maxdepth 1 -mindepth 1 -exec rm -rf {} \;
echo "-- DONE!"
