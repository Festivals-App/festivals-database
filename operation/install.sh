#!/bin/bash
#
# install.sh 1.0.0
#
# Enables the firewall, installs the newest go and the festivals-server and starts it as a service.
#
# (c)2020 Simon Gaus
#

# check & get password
if [ $# -ne 3 ]; then
    echo $0: usage: sudo ./deploy_centos <root_pw> <read_only_pw> <read_write_pw>
    exit 1
fi

#store in variables
root_password=$1
read_only_password=$2
read_write_password=$3

# Enables and configures the firewall.
# Supported firewalls: ufw and firewalld
# This step is skipped under macOS.
#
if command -v firewalld > /dev/null; then

  systemctl enable firewalld >/dev/null
  systemctl start firewalld >/dev/null
  echo "Enabled firewalld"
  sleep 1

  firewall-cmd --permanent --new-service=festivals-server >/dev/null
  firewall-cmd --permanent --service=festivals-server --set-description="A live and lightweight go server app providing the FestivalsAPI." >/dev/null
  firewall-cmd --permanent --service=festivals-server --add-port=10439/tcp >/dev/null
  firewall-cmd --permanent --add-service=festivals-server >/dev/null
  firewall-cmd --reload >/dev/null
  echo "Added festivals-server.service to firewalld"
  sleep 1

elif command -v ufw > /dev/null; then

  ufw default deny incoming
  ufw default allow outgoing
  ufw allow OpenSSH
  yes | sudo ufw enable >/dev/null
  echo "Enabled ufw"
  sleep 1

  ufw allow 10439/tcp
  echo "Added festivals-server to ufw"
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "No firewall detected and not on macOS. Exiting."
  exit 1
fi

# install mysql
dnf install mysql-server --assumeyes

# launch on startup and launch mysql
systemctl enable mysqld
systemctl start mysqld

# run secure script
printf "%s\n y\n %s\n %s\n y\n y\n y\n y\n" "$root_password" "$root_password" "$root_password" | mysql_secure_installation

# enable mysql in firewall
firewall-cmd --permanent --add-service=mysql
firewall-cmd --reload

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
