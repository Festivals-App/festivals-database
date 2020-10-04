# check & get password
if [ $# -ne 1 ]; then
    echo $0: usage: mysql_setup new_password
    exit 1
fi

#store in variable
root_password=$1

# launch on startup and launch firewalld
systemctl enable firewalld
systemctl start firewalld

# install mysql
dnf install mysql-server --assumeyes

# launch on startup and launch mysql
systemctl enable mysqld
systemctl start mysqld

# run secure script
printf "%s\n y\n %s\n %s\n y\n y\n y\n y\n" "$root_password" "$root_password" "$root_password" | mysql_secure_installation

# enable mysql in firewall
sudo firewall-cmd --add-service=mysql
sudo firewall-cmd --permanent --add-service=mysql

dnf install unzip --assumeyes

# dowload database-server repo
curl -L -O https://github.com/festivals-app/festivals-database/archive/main.zip
unzip main.zip
rm main.zip
