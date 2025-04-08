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
database_user="mysql"

# ─────────────────────────────────────────────────────────────────────────────
# 📁 Setup Working Directory
# ─────────────────────────────────────────────────────────────────────────────
WORK_DIR="/usr/local/festivals-database/install"
mkdir -p "$WORK_DIR" && cd "$WORK_DIR" || { echo -e "\n\033[1;31m❌  ERROR: Failed to create/access working directory!\033[0m\n"; exit 1; }
echo -e "\n📂  Working directory set to \e[1;34m$WORK_DIR\e[0m"
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🖥  Detect System OS and Architecture
# ─────────────────────────────────────────────────────────────────────────────
if [ "$(uname -s)" = "Darwin" ]; then
    os="darwin"
elif [ "$(uname -s)" = "Linux" ]; then
    os="linux"
else
    echo -e "\n🚨  ERROR: Unsupported OS. Exiting.\n"
    exit 1
fi
if [ "$(uname -m)" = "x86_64" ]; then
    arch="amd64"
elif [ "$(uname -m)" = "arm64" ]; then
    arch="arm64"
else
    echo -e "\n🚨  ERROR: Unsupported CPU architecture. Exiting.\n"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# 📦 Download latest release
# ─────────────────────────────────────────────────────────────────────────────
file_url="https://github.com/Festivals-App/festivals-database/releases/latest/download/festivals-database-node-$os-$arch.tar.gz"
echo -e "\n📥  Downloading latest FestivalsApp Database Server release..."
curl --progress-bar -L "$file_url" -o festivals-database.tar.gz
echo -e "📦  Extracting archive..."
tar -xf festivals-database.tar.gz

# ─────────────────────────────────────────────────────────────────────────────
# 📦 Install MySQL Server
# ─────────────────────────────────────────────────────────────────────────────
echo -e "\n🗂️  Installing MySQL server..."
apt-get install mysql-server -y > /dev/null 2>&1
echo -e "✅  MySQL server installed."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔥 Enable and Configure Firewall
# ─────────────────────────────────────────────────────────────────────────────
ufw allow mysql > /dev/null
echo -e "✅  Added MySQL service to UFW rules."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔄 Enable & Start MySQL Service
# ─────────────────────────────────────────────────────────────────────────────
systemctl enable mysql &>/dev/null && systemctl start mysql &>/dev/null
echo -e "✅  MySQL service is up and running."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔐 Install MySQL Credential File
# ─────────────────────────────────────────────────────────────────────────────
credentialsFile=/usr/local/festivals-database/mysql.conf
cat << EOF > $credentialsFile
# festivals-database configuration file v1.0
# TOML 1.0.0-rc.2+

[client]
user = 'festivals.api.backup'
password = '$backup_password'
host = 'localhost'
EOF
if [ -f "$credentialsFile" ]; then
    echo -e "✅  MySQL backup credential file successfully created at \e[1;34m$credentialsFile\e[0m"
else
    echo -e "\n🚨  ERROR: Failed to create MySQL backup credential file. Exiting.\n"
    exit 1
fi
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔑 Secure MySQL
# ─────────────────────────────────────────────────────────────────────────────
chmod +x secure-mysql.sh
./secure-mysql.sh "$root_password"
echo -e "✅  MySQL security script executed."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔑 Configure MySQL Certificates
# ─────────────────────────────────────────────────────────────────────────────
find /var/lib/mysql -name "*.pem" | xargs rm -r


mv festivals_mysql_template.cnf /etc/mysql/mysql.conf.d/festivals-mysqld.cnf

# ─────────────────────────────────────────────────────────────────────────────
# 🛠️  Configure MySQL Database and Users
# ─────────────────────────────────────────────────────────────────────────────
mysql -e "source $WORK_DIR/create_database.sql"
mysql -e "CREATE USER 'festivals.api.backup'@'localhost' IDENTIFIED BY '$backup_password' REQUIRE SUBJECT '/CN=FestivalsApp Database Client';"
mysql -e "GRANT ALL PRIVILEGES ON festivals_api_database.* TO 'festivals.api.backup'@'localhost';"
mysql -e "CREATE USER 'festivals.api.reader'@'%' IDENTIFIED BY '$read_only_password' REQUIRE SUBJECT '/CN=FestivalsApp Database Client';"
mysql -e "GRANT SELECT ON festivals_api_database.* TO 'festivals.api.reader'@'%';"
mysql -e "CREATE USER 'festivals.api.writer'@'%' IDENTIFIED BY '$read_write_password' REQUIRE SUBJECT '/CN=FestivalsApp Database Client';"
mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON festivals_api_database.* TO 'festivals.api.writer'@'%';"
mysql -e "FLUSH PRIVILEGES;"
echo -e "✅  Database and users created."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 📂 Setup Database Backup Directory
# ─────────────────────────────────────────────────────────────────────────────
mkdir -p /srv/festivals-database/backups
mv backup.sh /srv/festivals-database/backups/backup.sh
chmod +x /srv/festivals-database/backups/backup.sh
echo -e "✅  Database backup directory and script configured."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# ⏳ Install Cronjob for Daily Backup at 3 AM
# ─────────────────────────────────────────────────────────────────────────────
echo -e "0 3 * * * $database_user /srv/festivals-database/backups/backup.sh" | tee -a /etc/cron.d/festivals_database_backup > /dev/null
echo -e "✅  Cronjob installed! Backup will run daily at \e[1;34m3 AM\e[0m"

# ─────────────────────────────────────────────────────────────────────────────
# 🔑 Set Appropriate Permissions
# ─────────────────────────────────────────────────────────────────────────────
chown -R "$database_user":"$database_user" /usr/local/festivals-database
chmod -R 761 /usr/local/festivals-database
chown -R "$database_user":"$database_user" /srv/festivals-database
chmod -R 761 /srv/festivals-database
echo -e "\n🔐 Set Appropriate Permissions."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 📦 Install FestivalsApp Database Node
# ─────────────────────────────────────────────────────────────────────────────
echo -e "\n🗂️  Installing FestivalsApp Database Node..."
sleep 1
mkdir -p "/usr/local/festivals-database-node" || { echo -e "\n\033[1;31m❌  ERROR: Failed to create festivals-database-node directory!\033[0m\n"; exit 1; }
mv festivals-database-node /usr/local/bin/festivals-database-node || {
    echo -e "\n🚨  ERROR: Failed to install FestivalsApp Database Node binary. Exiting.\n"
    exit 1
}
echo -e "✅  Installed FestivalsApp Database Node to \e[1;34m/usr/local/bin/festivals-database-node\e[0m."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🛠  Install Server Configuration File
# ─────────────────────────────────────────────────────────────────────────────
mv config_template.toml /etc/festivals-database-node.conf
if [ -f "/etc/festivals-database-node.conf" ]; then
    echo -e "✅  Configuration file moved to \e[1;34m/etc/festivals-database-node.conf\e[0m."
else
    echo -e "\n🚨  ERROR: Failed to move configuration file. Exiting.\n"
    exit 1
fi
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 📂  Prepare Log Directory
# ─────────────────────────────────────────────────────────────────────────────
mkdir -p /var/log/festivals-database-node || {
    echo -e "\n🚨  ERROR: Failed to create log directory. Exiting.\n"
    exit 1
}
echo -e "✅  Log directory created at \e[1;34m/var/log/festivals-database-node\e[0m."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔍 Detect Web Server User
# ─────────────────────────────────────────────────────────────────────────────
WEB_USER="www-data"
if ! id -u "$WEB_USER" &>/dev/null; then
    WEB_USER="www"
    if ! id -u "$WEB_USER" &>/dev/null; then
        echo -e "\n\033[1;31m❌  ERROR: Web server user not found! Exiting.\033[0m\n"
        exit 1
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 🔄 Prepare Remote Update Workflow
# ─────────────────────────────────────────────────────────────────────────────
mv update_node.sh /usr/local/festivals-database-node/update.sh
chmod +x /usr/local/festivals-database-node/update.sh
cp /etc/sudoers /tmp/sudoers.bak
echo "$WEB_USER ALL = (ALL) NOPASSWD: /usr/local/festivals-database-node/update.sh" >> /tmp/sudoers.bak

# Validate and replace sudoers file if syntax is correct
if visudo -cf /tmp/sudoers.bak &>/dev/null; then
    sudo cp /tmp/sudoers.bak /etc/sudoers
    echo -e "✅  Updated sudoers file successfully."
else
    echo -e "\n🚨  ERROR: Could not modify /etc/sudoers file. Please do this manually. Exiting.\n"
    exit 1
fi
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🔥 Enable and Configure Firewall
# ─────────────────────────────────────────────────────────────────────────────

if command -v ufw > /dev/null; then
    echo -e "\n🔥  Configuring UFW firewall..."
    mv ufw_app_profile /etc/ufw/applications.d/festivals-database-node
    ufw allow festivals-database-node >/dev/null
    echo -e "✅  Added festivals-database-node to UFW with port 22397."
    sleep 1
elif ! [ "$(uname -s)" = "Darwin" ]; then
    echo -e "\n🚨  ERROR: No firewall detected and not on macOS. Exiting.\n"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# ⚙️  Install Systemd Service
# ─────────────────────────────────────────────────────────────────────────────

if command -v service > /dev/null; then
    echo -e "\n🚀  Configuring systemd service..."
    if ! [ -f "/etc/systemd/system/festivals-database-node.service" ]; then
        mv service_template.service /etc/systemd/system/festivals-database-node.service
        echo -e "✅  Created systemd service configuration."
        sleep 1
    fi
    systemctl enable festivals-database-node > /dev/null
    echo -e "✅  Enabled systemd service for FestivalsApp Database Node."
    sleep 1
elif ! [ "$(uname -s)" = "Darwin" ]; then
    echo -e "\n🚨  ERROR: Systemd is missing and not on macOS. Exiting.\n"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# 🔑 Set Appropriate Permissions
# ─────────────────────────────────────────────────────────────────────────────
chown -R "$WEB_USER":"$WEB_USER" /usr/local/festivals-database-node
chown -R "$WEB_USER":"$WEB_USER" /var/log/festivals-database-node
chown "$WEB_USER":"$WEB_USER" /etc/festivals-database-node.conf
echo -e "\n🔐  Set Appropriate Permissions."
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🧹 Cleanup Installation Files
# ─────────────────────────────────────────────────────────────────────────────
echo -e "\n🧹  Cleaning up installation files..."
cd /usr/local/festivals-database || exit
rm -R /usr/local/festivals-database/install
sleep 1

# ─────────────────────────────────────────────────────────────────────────────
# 🎉 COMPLETE Message
# ─────────────────────────────────────────────────────────────────────────────
echo -e "\n\033[1;32m══════════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;32m✅  INSTALLATION COMPLETE! 🚀\033[0m"
echo -e "\033[1;32m══════════════════════════════════════════════════════════════════════════\033[0m"
echo -e "\n📂 \033[1;34mBefore starting, you need to:\033[0m"
echo -e "\n   \033[1;34m1. Configure the mTLS certificates.\033[0m"
echo -e "   \033[1;34m2. Configuring the FestivlasApp Root CA.\033[0m"
echo -e "   \033[1;34m3. Update the configuration file at:\033[0m"
echo -e "\n   \033[1;32m    /etc/mysql/mysql.conf.d/mysqld.cnf\033[0m"
echo -e "   \033[1;34m4. Update the configuration file at:\033[0m"
echo -e "\n   \033[1;32m    /etc/festivals-database-node.conf\033[0m"
echo -e "\n🔹 \033[1;34mThen start the server manually:\033[0m"
echo -e "\n   \033[1;32m    sudo systemctl start festivals-database-node\033[0m"
echo -e "\n\033[1;32m══════════════════════════════════════════════════════════════════════════\033[0m\n"
sleep 1