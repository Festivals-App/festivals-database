#!/bin/bash
#
# install.sh 1.0.0
#
# Enables the firewall, installs the newest mysql, starts it as a service,
# configures it to be used as the database server for the FestivalsAPI and setup
# the backup routines.
#
# (c)2020-2021 Simon Gaus
#

# Check if all passwords are supplied
#
if [ $# -ne 4 ]; then
    echo "$0: usage: sudo ./install.sh <mysql_root_pw> <mysql_backup_pw> <read_only_pw> <read_write_pw>"
    exit 1
fi

# Store passwords in variables
#
root_password=$1
backup_password=$2
read_only_password=$3
read_write_password=$4
echo "Passwords are valid"
sleep 1

# Store username in variable
#
# Usign this because whoami would return root if the script is called with sudo!
#
current_user=$(who mom likes | awk '{print $1}')

# Create and move to project directory
#
echo "Creating project directory"
sleep 1
mkdir /usr/local/festivals-database
cd /usr/local/festivals-database || exit
chown -R $current_user:$current_user .
chmod -R 761 .

# Install mysql if needed.
#
echo "Installing mysql-server..."
apt-get install mysql-server -y > /dev/null;

# Enables and configures the firewall.
# Supported firewalls: ufw and firewalld
# This step is skipped under macOS.
#
ufw allow mysql
echo "Added mysql service to ufw rules"
sleep 1

# Launch mysql on startup
#
systemctl enable mysql > /dev/null
systemctl start mysql > /dev/null
echo "Enabled and started mysql systemd service."
sleep 1

# Install mysql credential file
#
echo "Installing mysql credential file"
sleep 1
credentialsFile=/usr/local/festivals-database/mysql.conf
cat << EOF > $credentialsFile
# festivals-databse configuration file v1.0
# TOML 1.0.0-rc.2+

[client]
user = 'root'
password = '$root_password'
host = 'localhost'

[mysqldump]
user = 'festivals.api.backup'
password = '$backup_password'
host = 'localhost'
EOF

chown -R $current_user:$current_user /usr/local/festivals-database/mysql.conf
chmod -R 761 /usr/local/festivals-database/mysql.conf


# Download and run mysql secure script
#
echo "Downloading database security script"
curl --progress-bar -L -o secure-mysql.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/secure-mysql.sh
chmod +x secure-mysql.sh
./secure-mysql.sh "$root_password"

# Download database creation script
#
echo "Downloading database creation script..."
curl --progress-bar -L -o create_database.sql https://raw.githubusercontent.com/Festivals-App/festivals-database/main/database_scripts/create_database.sql

# Run database creation script and configure users
#
echo "Configuring mysql"
sleep 1
mysql -e "source /usr/local/festivals-database/create_database.sql"
echo "Create local backup user"
mysql -e "CREATE USER 'festivals.api.backup'@'localhost' IDENTIFIED BY '$backup_password';"
mysql -e "GRANT ALL PRIVILEGES ON festivals_api_database.* TO 'festivals.api.backup'@'localhost';"
sleep 1
echo "Create read remote user"
mysql -e "CREATE USER 'festivals.api.reader'@'%' IDENTIFIED BY '$read_only_password';"
mysql -e "GRANT SELECT ON festivals_api_database.* TO 'festivals.api.reader'@'%';"
sleep 1
echo "Create read/write remote user"
mysql -e "CREATE USER 'festivals.api.writer'@'%' IDENTIFIED BY '$read_write_password';"
mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON festivals_api_database.* TO 'festivals.api.writer'@'%';"
sleep 1
mysql -e "FLUSH PRIVILEGES;"

# Create the backup directory
#
echo "Create backup directory"
sleep 1
mkdir -p /srv/festivals-database/backups
cd /srv/festivals-database/backups || exit
chown -R $current_user:$current_user /srv/festivals-database
chmod -R 761 /srv/festivals-database

# Download the backup script
#
echo "Downloading database creation script"
curl --progress-bar -L -o backup.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/backup.sh
chown -R $current_user:$current_user /srv/festivals-database/backups/backup.sh
chmod -R 761 /srv/festivals-database/backups/backup.sh
chmod +x /srv/festivals-database/backups/backup.sh

# Installing a cronjob to run the backup every day at 3 pm.
#
echo "Installing a cronjob to periodically run a backup"
sleep 1
echo "0 3 * * * $current_user /srv/festivals-database/backups/backup.sh" | sudo tee -a /etc/cron.d/festivals_database_backup

# Cleanup
#
echo "Cleanup"
sleep 1
cd /usr/local/festivals-database
rm secure-mysql.sh
rm create_database.sql

echo "Done."
sleep 1
