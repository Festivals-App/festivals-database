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

# Check if the backup user exists
#
database_user_exists="$(mysql -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'festivals.api.backup')")"
if [ "$database_user_exists" != 1 ]; then
    echo "This restore script only works if the database was properly setup via the install scrip."
    sleep 1
    exit 1
fi

# Check if the api read user exists
#
reader_user_exists="$(mysql -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'festivals.api.reader')")"
if [ "$reader_user_exists" != 1 ]; then
    echo "This restore script only works if the database was properly setup via the install scrip."
    sleep 1
    exit 1
fi

# Check if the api write user exists
#
writer_user_exists="$(mysql -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'festivals.api.writer')")"
if [ "$writer_user_exists" != 1 ]; then
    echo "This restore script only works if the database was properly setup via the install scrip."
    sleep 1
    exit 1
fi

