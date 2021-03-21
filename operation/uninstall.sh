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
systemctl stop mysql > /dev/null
systemctl disable mysql > /dev/null
echo "Removed and disbaled mysql systemd service."
sleep 1

# Remove firewall rules.
# Supported firewalls: ufw and firewalld
# This step is skipped under macOS.
#
ufw delete allow mysql
echo "Removed ufw configuration"
sleep 1

# Uninstall mysql
#
echo "Uninstalling mysql-server"
apt-get remove mysql-server -y > /dev/null;
apt-get autoremove -y > /dev/null;
rm -r /var/lib/mysql*

echo "Done"
sleep 1
