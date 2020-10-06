# Deploy MySQL CS 8 on CentOS 8

1. Download deploy script
```bash
curl -o deploy_centos.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/deploy_centos.sh
chmod +x deploy_centos.sh
./deploy_centos.sh <mysql root password>  <mysql read_only password> <mysql read_write password>
```
