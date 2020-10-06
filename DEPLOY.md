
# Manually deploying MySQL


## Deploy MySQL on Ubuntu 20 LTS

```bash
TBI
```

## Deploy MySQL on CentOS 8

```bash
# run deploy script
curl -o deploy_centos.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/deploy_centos.sh
chmod +x deploy_centos.sh
sudo ./deploy_centos.sh <mysql root password>  <mysql read_only password> <mysql read_write password>
# if it is for testing
sudo mysql -uroot -p<password> -e "source ./festivals-database-main/database_scripts/insert_testdata.sql"
```
