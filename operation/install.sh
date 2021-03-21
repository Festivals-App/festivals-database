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
if [ $# -ne 3 ]; then
    echo "$0: usage: sudo ./install.sh <mysql_root_pw> <read_only_pw> <read_write_pw>"
    exit 1
fi

# Store passwords in variables
#
root_password=$1
read_only_password=$2
read_write_password=$3
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
chmod -R 740 .

# Enables and configures the firewall.
# Supported firewalls: ufw and firewalld
# This step is skipped under macOS.
#
if command -v firewalld > /dev/null; then

  firewall-cmd --permanent --add-service=mysql >/dev/null
  firewall-cmd --reload >/dev/null
  echo "Added mysql service to firewalld rules"
  sleep 1

elif command -v ufw > /dev/null; then

  ufw allow mysql
  echo "Added mysql service to ufw rules"
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "No firewall detected and not on macOS. Exiting."
  sleep 1
  exit 1
fi

# Install mysql if needed.
#
if ! command -v mysqld > /dev/null; then

  if command -v dnf > /dev/null; then

    echo "Installing mysql-server"
    dnf install mysql-server --assumeyes > /dev/null;

  elif command -v apt-get > /dev/null; then

    echo "Installing mysql-server"
    apt-get install mysql-server -y > /dev/null;

  else
    echo "Unable to install mysql-server. Exiting."
    sleep 1
    exit 1
  fi

else
  echo "Already installed mysql-server."
  sleep 1
fi

# Launch mysql on startup
#
if command -v systemctl > /dev/null; then

  if systemctl list-units --full -all | grep -Fq "mysql.service"; then
    systemctl enable mysql > /dev/null
    systemctl start mysql > /dev/null
  else
    systemctl enable mysqld > /dev/null
    systemctl start mysqld > /dev/null
  fi

  echo "Enabled systemd service."
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "Systemd is missing and not on macOS. Exiting."
  exit 1
fi

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
EOF

# Download and run mysql secure script
#
echo "Downloading database security script"
curl --progress-bar -L -o secure-mysql.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/secure-mysql.sh
chmod +x secure-mysql.sh
./secure-mysql.sh "$root_password"

# Download and run database creation script, add and configure users
#
echo "Downloading database creation script"
curl --progress-bar -L -o create_database.sql https://raw.githubusercontent.com/Festivals-App/festivals-database/main/database_scripts/create_database.sql
echo "Configuring mysql"
sleep 1
mysql --defaults-extra-file=$credentialsFile -e "source /usr/local/festivals-database/create_database.sql"
mysql --defaults-extra-file=$credentialsFile -e "CREATE USER 'festivals.api.reader'@'%' IDENTIFIED BY '$read_only_password';"
mysql --defaults-extra-file=$credentialsFile -e "GRANT SELECT ON festivals_api_database.* TO 'festivals.api.reader'@'%';"
mysql --defaults-extra-file=$credentialsFile -e "CREATE USER 'festivals.api.writer'@'%' IDENTIFIED BY '$read_write_password';"
mysql --defaults-extra-file=$credentialsFile -e "GRANT SELECT, INSERT, UPDATE, DELETE ON festivals_api_database.* TO 'festivals.api.writer'@'%';"
mysql --defaults-extra-file=$credentialsFile -e "FLUSH PRIVILEGES;"

# Create the backup directory
#
echo "Create backup directory"
sleep 1
mkdir -p /srv/festivals-database/backups
cd /srv/festivals-database/backups || exit
chown -R $current_user:$current_user /srv/festivals-database
chmod -R 740 /srv/festivals-database

# Download the backup script
#
echo "Downloading database creation script"
curl --progress-bar -L -o backup.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/backup.sh
chmod +x backup.sh

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
