#!/bin/bash
#
# install.sh 1.0.0
# 
# (c)2020-2022 Simon Gaus
#

# Test for web server user
#
WEB_USER="www-data"
id -u "$WEB_USER" &>/dev/null;
if [ $? -ne 0 ]; then
  WEB_USER="www"
  if [ $? -ne 0 ]; then
    echo "Failed to find user to run web server. Exiting."
    exit 1
  fi
fi

# Move to working dir
#
mkdir -p /usr/local/festivals-database-node/install || { echo "Failed to create working directory. Exiting." ; exit 1; }
cd /usr/local/festivals-database-node/install || { echo "Failed to access working directory. Exiting." ; exit 1; }
echo "Installing festivals-website-node using port 22397."
sleep 1

# Get system os
#
if [ "$(uname -s)" = "Darwin" ]; then
  os="darwin"
elif [ "$(uname -s)" = "Linux" ]; then
  os="linux"
else
  echo "System is not Darwin or Linux. Exiting."
  exit 1
fi

# Get systems cpu architecture
#
if [ "$(uname -m)" = "x86_64" ]; then
  arch="amd64"
elif [ "$(uname -m)" = "arm64" ]; then
  arch="arm64"
else
  echo "System is not x86_64 or arm64. Exiting."
  exit 1
fi

# Build url to latest binary for the given system
#
file_url="https://github.com/Festivals-App/festivals-database/releases/latest/download/festivals-database-node-$os-$arch.tar.gz"
echo "The system is $os on $arch."
sleep 1

# Install festivals-database-node to /usr/local/bin/festivals-database-node. TODO: Maybe just link to /usr/local/bin?
#
echo "Downloading newest festivals-database-node binary release..."
curl -L "$file_url" -o festivals-database-node.tar.gz
tar -xf festivals-database-node.tar.gz
mv festivals-database-node /usr/local/bin/festivals-database-node || { echo "Failed to install festivals-database-node binary. Exiting." ; exit 1; }
echo "Installed the festivals-database-node binary to '/usr/local/bin/festivals-database-node'."
sleep 1

## Install server config file
mv config_template.toml /etc/festivals-database-node.conf
echo "Moved default festivals-database-node config to '/etc/festivals-database-node.conf'."
sleep 1

## Prepare log directory
mkdir /var/log/festivals-database-node || { echo "Failed to create log directory. Exiting." ; exit 1; }
echo "Created log directory at '/var/log/festivals-database-node'."

## Prepare node update workflow
#
mv update_node.sh /usr/local/festivals-database-node/update.sh
chmod +x /usr/local/festivals-database-node/update.sh
cp /etc/sudoers /tmp/sudoers.bak
echo "$WEB_USER ALL = (ALL) NOPASSWD: /usr/local/festivals-database-node/update.sh" >> /tmp/sudoers.bak
# Check syntax of the backup file to make sure it is correct.
visudo -cf /tmp/sudoers.bak
if [ $? -eq 0 ]; then
  # Replace the sudoers file with the new only if syntax is correct.
  sudo cp /tmp/sudoers.bak /etc/sudoers
else
  echo "Could not modify /etc/sudoers file. Please do this manually." ; exit 1;
fi

# Enable and configure the firewall.
#
if command -v ufw > /dev/null; then

  mv ufw_app_profile /etc/ufw/applications.d/festivals-database-node
  ufw allow festivals-database-node >/dev/null
  echo "Added festivals-database-node to ufw using port 22397."
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "No firewall detected and not on macOS. Exiting."
  exit 1
fi

# Install systemd service
#
if command -v service > /dev/null; then

  if ! [ -f "/etc/systemd/system/festivals-database-node.service" ]; then
    mv service_template.service /etc/systemd/system/festivals-database-node.service
    echo "Created systemd service."
    sleep 1
  fi

  systemctl enable festivals-database-node > /dev/null
  echo "Enabled systemd service."
  sleep 1

elif ! [ "$(uname -s)" = "Darwin" ]; then
  echo "Systemd is missing and not on macOS. Exiting."
  exit 1
fi

## Set appropriate permissions
#
chown -R "$WEB_USER":"$WEB_USER" /usr/local/festivals-database-node
chown -R "$WEB_USER":"$WEB_USER" /var/log/festivals-database-node
chown "$WEB_USER":"$WEB_USER" /etc/festivals-database-node.conf
echo "Seting appropriate permissions..."
sleep 1

# Cleanup installation
#
echo "Cleanup..."
cd /usr/local/festivals-database-node || exit
rm -R /usr/local/festivals-database-node/install
sleep 1

echo "Done!"
sleep 1

echo "You can start the festivals-database-node manually by running 'systemctl start festivals-database-node' after you updated the configuration file at '/etc/festivals-database-node.conf'"
sleep 1