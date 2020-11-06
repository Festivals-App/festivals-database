#!/bin/bash
#
# install.sh 1.0.0
#
# Enables the firewall, installs the newest mysql, starts it as a service
# and configures it to be used as the database server for the FestivalsAPI.
#
# (c)2020 Simon Gaus
#

# Check if all passwords are supplied
#
if [ $# -ne 3 ]; then
    echo "$0: usage: sudo ./deploy_centos <root_pw> <read_only_pw> <read_write_pw>"
    exit 1
fi

# Store passwords in variables
#
root_password=$1
read_only_password=$2
read_write_password=$3
echo "Passwords are valid"
sleep 1

# Enables and configures the firewall.
# Supported firewalls: ufw and firewalld
# This step is skipped under macOS.
#
if command -v firewalld > /dev/null; then

  systemctl enable firewalld >/dev/null
  systemctl start firewalld >/dev/null
  echo "Enabled firewalld"
  sleep 1

  firewall-cmd --permanent --add-service=mysql
  firewall-cmd --reload
  echo "Added mysql service to firewalld rules"
  sleep 1

elif command -v ufw > /dev/null; then

  ufw default deny incoming
  ufw default allow outgoing
  ufw allow OpenSSH
  yes | sudo ufw enable >/dev/null
  echo "Enabled ufw"
  sleep 1

  ufw allow mysql
  echo "Added mysql service to ufw rules"
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "No firewall detected and not on macOS. Exiting."
  exit 1
fi

# Install mysql if needed.
#
if ! command -v mysqld > /dev/null; then
  if command -v dnf > /dev/null; then
    echo "---> Installing mysql-server"
    dnf install mysql-server --assumeyes > /dev/null;
  elif command -v apt > /dev/null; then
    echo "---> Installing mysql-server"
    apt install mysql-server -y > /dev/null;
  else
    echo "Unable to install mysql-server. Exiting."
    sleep 1
    exit 1
  fi
else
  echo "---> Already installed mysql-server"
  sleep 1
fi

# launch on startup and launch mysql
systemctl enable mysqld
systemctl start mysqld

# run secure script
printf "%s\n y\n %s\n %s\n y\n y\n y\n y\n" "$root_password" "$root_password" "$root_password" | mysql_secure_installation

dnf install unzip --assumeyes

# dowload festivals-database repo
curl -L -O https://github.com/festivals-app/festivals-database/archive/main.zip
unzip main.zip
rm main.zip

# create database
mysql -uroot -p$root_password -e "source ./festivals-database-main/database_scripts/create_database.sql"
# create read-only user
mysql -uroot -p$root_password -e "CREATE USER 'festivals.api.reader'@'%' IDENTIFIED BY '$read_only_password';"
mysql -uroot -p$root_password -e "GRANT SELECT ON festivals_api_database.* TO 'festivals.api.reader'@'%';"
# create read/write user
mysql -uroot -p$root_password -e "CREATE USER 'festivals.api.writer'@'%' IDENTIFIED BY '$read_write_password';"
mysql -uroot -p$root_password -e "GRANT SELECT, INSERT, UPDATE, DELETE ON festivals_api_database.* TO 'festivals.api.writer'@'%';"

mysql -uroot -p$root_password -e "FLUSH PRIVILEGES;"

# remove repository
rm -R festivals-database-main

# remove this script
rm -- "$0"
