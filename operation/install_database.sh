#!/bin/bash
#
# install_database.sh - FestivalsApp Database Installer Script
#
# Enables the firewall, installs the latest version of MySQL, starts it as a service, 
# configures it as the database server for FestivalsAPI, and sets up backup routines.
#
# (c)2020-2025 Simon Gaus
#

# ─────────────────────────────────────────────────────────────────────────────
# 🛑 Check if all parameters are supplied
# ─────────────────────────────────────────────────────────────────────────────
if [ $# -ne 4 ]; then
    echo -e "\n\033[1;31m🚨  ERROR: Missing parameters!\033[0m"
    echo -e "\n\033[1;34m🔹  USAGE:\033[0m sudo ./install_database.sh \033[1;32m<mysql_root_pw> <mysql_backup_pw> <read_only_pw> <read_write_pw>\033[0m"
    echo -e "\n\033[1;34m⚠️  REQUIREMENTS:\033[0m Run as \033[1;33mroot\033[0m or with \033[1;33msudo\033[0m."
    echo -e "\n\033[1;31m❌  Exiting.\033[0m\n"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# 🎯 Store parameters in variables
# ─────────────────────────────────────────────────────────────────────────────
root_password=$1
backup_password=$2
read_only_password=$3
read_write_password=$4

# ─────────────────────────────────────────────────────────────────────────────
# 🏗️  Create and Move to Project Directory
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n📂 Creating project directory..."
sleep 1
mkdir -p /usr/local/festivals-database || { echo -e "\n🚨 ERROR: Failed to create project directory. Exiting."; exit 1; }
cd /usr/local/festivals-database || { echo -e "\n🚨 ERROR: Failed to access project directory. Exiting."; exit 1; }

database_user="mysql"

# ─────────────────────────────────────────────────────────────────────────────
# 📦 Install MySQL Server
# ─────────────────────────────────────────────────────────────────────────────
echo -e "\n\n\n🚀  Installing MySQL server..."
apt-get install mysql-server -y > /dev/null 2>&1
echo -e "\n✅  MySQL server installed."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔥 Enable and Configure Firewall
# ─────────────────────────────────────────────────────────────────────────────

ufw allow mysql > /dev/null
echo -e "\n✅ Added MySQL service to UFW rules."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔄 Enable & Start MySQL Service
# ─────────────────────────────────────────────────────────────────────────────
echo -e "\n\n\n▶️  Enabling and starting MySQL service..."
systemctl enable mysql &>/dev/null && systemctl start mysql &>/dev/null

echo -e "\n✅  MySQL service is up and running.\n"
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔐 Install MySQL Credential File
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n\n\n📂  Installing MySQL credential file to project directory..."
sleep 1

credentialsFile=/usr/local/festivals-identity-server/mysql.conf
cat << EOF > $credentialsFile
# festivals-database configuration file v1.0
# TOML 1.0.0-rc.2+

[client]
user = 'festivals.api.backup'
password = '$backup_password'
host = 'localhost'
EOF

if [ -f "$credentialsFile" ]; then
    echo -e "\n✅  MySQL credential file successfully created at \e[1;34m$credentialsFile\e[0m\n"
else
    echo -e "\n🚨  ERROR: Failed to create MySQL credential file. Exiting.\n"
    exit 1
fi
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔑 Secure MySQL
# ─────────────────────────────────────────────────────────────────────────────
echo -e "\n\n\n🔐  Securing MySQL..."
curl --progress-bar -L -o secure-mysql.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/secure-mysql.sh
chmod +x secure-mysql.sh
./secure-mysql.sh "$root_password"
echo -e "\n✅  MySQL secured.\n"
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🛠️  Configure MySQL Database and Users
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n\n\n🛠️ Configuring MySQL database..."
echo -e "\n📦 Downloading database creation script..."
curl --progress-bar -L -o create_database.sql https://raw.githubusercontent.com/Festivals-App/festivals-database/main/database_scripts/create_database.sql

mysql -e "source /usr/local/festivals-database/create_database.sql"

# Create database users

echo -e "\n🔹 Creating local backup user..."
mysql -e "CREATE USER 'festivals.api.backup'@'localhost' IDENTIFIED BY '$backup_password' REQUIRE SUBJECT '/CN=FestivalsApp Database Client';"
mysql -e "GRANT ALL PRIVILEGES ON festivals_api_database.* TO 'festivals.api.backup'@'localhost';"
sleep 1

echo -e "\n🔹 Creating read-only remote user..."
mysql -e "CREATE USER 'festivals.api.reader'@'%' IDENTIFIED BY '$read_only_password' REQUIRE SUBJECT '/CN=FestivalsApp Database Client';"
mysql -e "GRANT SELECT ON festivals_api_database.* TO 'festivals.api.reader'@'%';"
sleep 1

echo -e "\n🔹 Creating read/write remote user..."
mysql -e "CREATE USER 'festivals.api.writer'@'%' IDENTIFIED BY '$read_write_password' REQUIRE SUBJECT '/CN=FestivalsApp Database Client';"
mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON festivals_api_database.* TO 'festivals.api.writer'@'%';"
sleep 1

mysql -e "FLUSH PRIVILEGES;"

# ─────────────────────────────────────────────────────────────────────────────
# 📂 Setup Backup Directory
# ─────────────────────────────────────────────────────────────────────────────
echo -e "\n\n\n💾  Setting up backup directory..."
mkdir -p /srv/festivals-database/backups
curl --progress-bar -L -o /srv/festivals-database/backups/backup.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/backup.sh
chmod +x /srv/festivals-database/backups/backup.sh
echo -e "\n✅  Backup directory and script configured.\n"
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# ⏳ Install Cronjob for Daily Backup at 3 AM
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n\n\n🕒  Installing a cronjob to periodically run a backup..."
sleep 1
echo -e "0 3 * * * $database_user /srv/festivals-database/backups/backup.sh" | tee -a /etc/cron.d/festivals_database_backup > /dev/null
echo -e "\n✅  Cronjob successfully installed! Backup will run daily at \e[1;34m3 AM\e[0m\n"

# ─────────────────────────────────────────────────────────────────────────────
# 🔑 Set Appropriate Permissions
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n\n\n🔑 Setting appropriate permissions..."
sleep 1
chown -R "$database_user":"$database_user" /usr/local/festivals-database
chmod -R 761 /usr/local/festivals-database
chown -R "$database_user":"$database_user" /srv/festivals-database
chmod -R 761 /srv/festivals-database

echo -e "\n✅  Set Appropriate Permissions.\n"
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🧹 Cleanup Installation Files
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n\n\n🧹 Cleaning up installation files..."
cd /usr/local/festivals-database || exit
rm -f secure-mysql.sh create_database.sql
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🎉 Final Message
# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n\n\n\n\033[1;32m══════════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;32m✅  DATABASE INSTALLATION COMPLETE! 🚀\033[0m"
echo -e "\033[1;32m══════════════════════════════════════════════════════════════════════════\033[0m"
sleep 1

echo -e "\n📂 \033[1;34mIn order for the festivals-server to access the database remotely, make sure to set the correct bind-address here:\033[0m"
echo -e "\n   \033[1;34m/etc/mysql/mysql.conf.d/mysqld.cnf\033[0m"

echo -e "\n\033[1;32m══════════════════════════════════════════════════════════════════════════\033[0m\n"
sleep 1
