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

# Remove database backup directory
#
rm -R /srv/festivals-database
echo "Removed database backup folder."
sleep 1

# Remove the cronjob that runs the backup
#
rm -f /etc/cron.d/festivals_database_backup
echo "Remove the cronjob that runs the backup"
sleep 1

# Quit mysql and remove from systemctl
#
if command -v systemctl > /dev/null; then

  if systemctl list-units --full -all | grep -Fq "mysql.service"; then
    systemctl stop mysql > /dev/null
    systemctl disable mysql > /dev/null
  else
    systemctl stop mysqld > /dev/null
    systemctl disable mysqld > /dev/null
  fi

  echo "Removed and disbaled systemd service."
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "Systemd is missing and not on macOS. Exiting."
  exit 1
fi

# Remove firewall rules.
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

  echo "Uninstalling mysql-server"
  dnf remove mysql mysql-server --assumeyes > /dev/null;
  rm -r /var/lib/mysql*

elif command -v apt-get > /dev/null; then

  echo "Uninstalling mysql-server"
  apt-get remove mysql-server -y > /dev/null;
  apt-get autoremove -y > /dev/null;
  rm -r /var/lib/mysql*

else
  echo "Unable to uninstall mysql-server. Exiting."
  sleep 1
  exit 1
fi

echo "Done"
sleep 1
