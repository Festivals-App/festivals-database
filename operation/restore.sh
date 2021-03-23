#!/bin/bash
#
# restore.sh 1.0.0
#
# <Description>
#
# (c)2021 Simon Gaus
#

# Check if url to backup is provided
#
if [ $# -ne 1 ]; then
    echo "$0: usage: sudo ./restore.sh <url_to_zipped_backup>"
    exit 1
fi

# Save backu url to variable
#
backup_url=$1

# Check if the backup user exists
#
database_user_exists="$(mysql -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'festivals.api.backup');")"
if [ "$database_user_exists" != 1 ]; then
    echo "This restore script only works if the database was properly setup via the install script. The backup user appears to be missing."
    sleep 1
    exit 1
fi

# Check if the api read user exists
#
reader_user_exists="$(mysql -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'festivals.api.reader');")"
if [ "$reader_user_exists" != 1 ]; then
    echo "This restore script only works if the database was properly setup via the install script. The api read user appears to be missing."
    sleep 1
    exit 1
fi

# Check if the api write user exists
#
writer_user_exists="$(mysql -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'festivals.api.writer');")"
if [ "$writer_user_exists" != 1 ]; then
    echo "This restore script only works if the database was properly setup via the install script. The api write user appears to be missing."
    sleep 1
    exit 1
fi

# Move to the project folder
#
cd /usr/local/festivals-database || exit

# Donwloading the backup file
#
echo "Downloading the backup..."
curl --progress-bar -L -o backup_zip.gz "$backup_url"

# Decompressing the backup file
#
echo "Decompressing the backup..."
gunzip -c backup_zip.gz > backup.sql

# Restoring the database
#
echo "Restoring the backup..."
mysql festivals_api_database < backup.sql
sleep 1

# Cleanup
#
echo "Checking all databases - this can take a while ..."
echo
sleep 1
mysqlcheck --auto-repair --all-databases
sleep 1

# Cleanup
#
echo "Cleanup"
sleep 1
rm backup_zip.gz
rm backup.sql

echo "Done!"
sleep 1