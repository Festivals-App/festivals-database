#!/bin/bash
#
# uninstall.sh 1.0.0
#
# Removes the firewall rules, stops and removes mysql and all local files
# associated with the FestivalsAPI database.
#
# (c)2020 Simon Gaus
#

# Remove database project directory
#
rm -R /usr/local/festivals-database
echo "Removed database project folder."
sleep 1

# Quit mysql and remove from systemd
#
if command -v service > /dev/null; then

  systemctl stop mysqld > /dev/null
  systemctl disbale mysqld > /dev/null
  echo "Removed and disbaled systemd service."
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "Systemd is missing and not on macOS. Exiting."
  exit 1
fi

# Disable and un-configure the firewall.
# Supported firewalls: ufw and firewalld
# This step is skipped under macOS.
#
if command -v firewalld > /dev/null; then

  firewall-cmd --permanent --remove-service=mysql >/dev/null
  firewall-cmd --reload >/dev/null
  echo "Removed firewalld configuration"
  sleep 1

elif command -v ufw > /dev/null; then

  ufw delete allow mysql
  echo "Removed ufw configuration"
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "No firewall detected and not on macOS. Exiting."
  exit 1
fi

# Uninstall mysql
#
if command -v dnf > /dev/null; then

  echo "---> Uninstalling mysql-server"
  dnf remove mysql mysql-server --assumeyes > /dev/null;
  rm -r /var/lib/mysql

elif command -v apt > /dev/null; then

  echo "---> Uninstalling mysql-server"
  apt remove mysql mysql-server -y > /dev/null;
  rm -r /var/lib/mysql

else
  echo "Unable to uninstall mysql-server. Exiting."
  sleep 1
  exit 1
fi
