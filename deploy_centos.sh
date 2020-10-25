# check & get password
if [ $# -ne 3 ]; then
    echo $0: usage: sudo ./deploy_centos root_pw read_only_pw read_write_pw
    exit 1
fi

#store in variable
root_password=$1
read_only_password=$2
read_write_password=$3

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
