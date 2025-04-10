# Development Deployment

This deployment guide explains how to deploy the FestivalsApp Database Server using certificates intended for development purposes.

## Prerequisites

This guide assumes you have already created a Virtual Machine (VM) by following the [VM deployment guide](https://github.com/Festivals-App/festivals-documentation/tree/main/deployment/vm-deployment).

Before starting the installation, ensure you have:

- Created and configured your VM
- SSH access secured and logged in as the admin user
- Your server's IP address (use `ip a` to check)
- A server name matching the Common Name (CN) for your mTLS certificate (e.g., `database-0.festivalsapp.home` for a hostname `database-0`).

I use the development wildcard server certificate (`CN=*festivalsapp.home`) for this guide.

  > **DON'T USE THIS IN PRODUCTION, SEE [festivals-pki](https://github.com/Festivals-App/festivals-pki) FOR SECURITY BEST PRACTICES FOR PRODUCTION**

## 1. Installing the FestivalsApp Database and Sidecar

Run the following commands to install the FestivalsApp Database and Sidecar:

```bash
curl -o install.sh https://raw.githubusercontent.com/Festivals-App/festivals-database/main/operation/install.sh
chmod +x install.sh
sudo ./install.sh <mysql_root_pw> <mysql_backup_pw> <read_only_pw> <read_write_pw>
```

The database config file is located at:

  > `/etc/mysql/mysql.conf.d/festivals-mysqld.cnf`

The database node config file is located at:

  > `/etc/festivals-database-node.conf`

You also need to provide certificates in the right format and location:

  > Root CA certificate           `/usr/local/festivals-database-node/ca.crt`  
  > Server certificate            `/usr/local/festivals-database-node/server.crt`  
  > Server key                    `/usr/local/festivals-database-node/server.key`  
  > MYSQL Root CA certificate     `/var/lib/mysql/ca.pem`  
  > MYSQL Server cert             `/var/lib/mysql/server-cert.pem`  
  > MYSQL Server key              `/var/lib/mysql/server-key.pem`  

Where the root CA certificate is required to validate incoming requests, the server certificate and key is required for the node server
to make outgoing connections via mTLS and the MYSQL certificate and key is required to connect to the database via SSL.
For instructions on how to manage and create the certificates see the [festivals-pki](https://github.com/Festivals-App/festivals-pki) repository.

## 2. Copying mTLS Certificates to the VM

Copy the server mTLS certificates from your development machine to the VM:

```bash
scp /opt/homebrew/etc/pki/ca.crt <user>@<ip-address>:.
scp /opt/homebrew/etc/pki/issued/server.crt <user>@<ip-address>:.
scp /opt/homebrew/etc/pki/private/server.key <user>@<ip-address>:.
```

Once copied, SSH into the VM and move them to the correct location:

```bash
sudo mv ca.crt /usr/local/festivals-database-node/ca.crt
sudo mv server.crt /usr/local/festivals-database-node/server.crt
sudo mv server.key /usr/local/festivals-database-node/server.key
```

Set the correct permissions:

```bash
# Change owner to web user
sudo chown www-data:www-data /usr/local/festivals-database-node/ca.crt
sudo chown www-data:www-data /usr/local/festivals-database-node/server.crt
sudo chown www-data:www-data /usr/local/festivals-database-node/server.key
# Set secure permissions
sudo chmod 640 /usr/local/festivals-database-node/ca.crt
sudo chmod 640 /usr/local/festivals-database-node/server.crt
sudo chmod 600 /usr/local/festivals-database-node/server.key
```

## 3. Configuring the MYSQL Certificates

Convert the mTLS server certificate to use it as the MYSQL certificates:

  > **DON'T USE THIS IN PRODUCTION, SEE [festivals-pki](https://github.com/Festivals-App/festivals-pki) FOR SECURITY BEST PRACTICES FOR PRODUCTION**

```bash
sudo openssl x509 -in /usr/local/festivals-database-node/ca.crt -out /var/lib/mysql/ca.pem -outform PEM
sudo openssl x509 -in /usr/local/festivals-database-node/server.crt -out /var/lib/mysql/server-cert.pem -outform PEM
sudo openssl rsa -in /usr/local/festivals-database-node/server.key -text | sudo tee /var/lib/mysql/server-key.pem
```

Set the correct permissions:

```bash
# Change owner to web user
sudo chown mysql:mysql /var/lib/mysql/ca.pem
sudo chown mysql:mysql /var/lib/mysql/server-cert.pem
sudo chown mysql:mysql /var/lib/mysql/server-key.pem
# Set secure permissions
sudo chmod 640 /var/lib/mysql/ca.pem
sudo chmod 640 /var/lib/mysql/server-cert.pem
sudo chmod 600 /var/lib/mysql/server-key.pem
```

## 4. Configuring the FestivalsApp Database

Open the configuration file:

```bash
sudo nano /etc/mysql/mysql.conf.d/festivals-mysqld.cnf
```

Set the bind-address and ssl certificates:

```ini

bind-address = 127.0.0.1
# For example: 
# bind-address = 192.168.8.188

ssl-ca = /var/lib/mysql/ca.pem
ssl-cert = /var/lib/mysql/server-cert.pem
ssl-key = /var/lib/mysql/server-key.pem
# For example: 
# ssl-ca = /var/lib/mysql/ca.pem
# ssl-cert = /var/lib/mysql/database-0-cert.pem
# ssl-key = /var/lib/mysql/database-0-key.pem
```

## 5. Configuring the FestivalsApp Database Node

Open the configuration file:

```bash
sudo nano /etc/festivals-database-node.conf
```

Set the server name and heartbeat endpoint:

```ini
[service]
bind-host = "<server name>"
# For example: 
# bind-host = "database-0.festivalsapp.home"

[database]
bind-address = "127.0.0.1"
# For example: 
# bind-address = "192.168.8.188"

[heartbeat]
endpoint = "<discovery endpoint>"
#For example: endpoint = "https://discovery.festivalsapp.home/loversear"

[authentication]
endpoint = "<authentication endpoint>"
# endpoint = "https://identity-0.festivalsapp.home:22580"
```

## Optional: Restore database backup

Copy the backup from the old server and copy to the new one

```bash
scp <user>@<host>:/srv/festivals-database/backups/<date>/festivals_api_database-<datetime>.gz ~/Desktop
scp ~/Desktop/festivals_api_database-<datetime>.gz <user>@<host>:.
```

Now decompress and import the backuped database into mysql

```bash
gzip -d festivals_api_database-<datetime>.gz
sudo mysql -uroot -p < festivals_api_database-<datetime>
```

And now let's restart the database and start the sidecar service:

```Bash
sudo systemctl restart mysql
sudo systemctl start festivals-database-node
```

## **🚀 The database and the sidecar service should now be running successfully. 🚀**

### Optional: Setting Up Local DNS Resolution  

For the services in the FestivalsApp backend to function correctly, proper DNS resolution is required.
This is because mTLS is configured to validate the client’s certificate identity based on its DNS hostname.  

If you don’t have a DNS server to manage DNS for your development VMs, you can manually configure DNS resolution
by adding the necessary entries to each server’s `/etc/hosts` file:  

```bash
sudo nano /etc/hosts
```

Add the following entries:  

```ini
<IP address> <server name>  
<Gateway IP address> <discovery endpoint>  

# Example:  
# 192.168.8.187 database-0.festivalsapp.home
# 192.168.8.185 identity-0.festivalsapp.home
# 192.168.8.186 discovery.festivalsapp.home
# ...
```

**Keep in mind that you will need to update each machine’s `hosts` file whenever you add a new VM or if any IP addresses change.**

### Testing

Lets login as the default admin user and get the server info:

```bash
curl -H "Api-Key: TEST_API_KEY_001" -u "admin@email.com:we4711" --cert /opt/homebrew/etc/pki/issued/api-client.crt --key /opt/homebrew/etc/pki/private/api-client.key --cacert /opt/homebrew/etc/pki/ca.crt https://identity-0.festivalsapp.home:22580/users/login
```

This should return a JWT Token `<Header.<Payload>.<Signatur>`

  > eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.
  > eyJVc2VySUQiOiIxIiwiVXNlclJvbGUiOjQyLCJVc2VyRmVzdGl2YWxzIjpbXSwiVXNlckFydGlzdHMiOltdLCJVc2VyTG9jYXRpb25zIjpbXSwiVXNlckV2ZW50cyI6W10sIlVzZXJMaW5rcyI6W10sIlVzZXJQbGFjZXMiOltdLCJVc2VySW1hZ2VzIjpbXSwiVXNlclRhZ3MiOltdLCJpc3MiOiJpZGVudGl0eS0wLmZlc3RpdmFsc2FwcC5ob21lIiwiZXhwIjoxNzQwMjMxMTQ4fQ.
  > geBq1pxEvqwjnKA5YTHQ8IjJc9mwkpsQIRy1kGc63oNXzyAhPrPJsepICXxr2yVmB0E8oDECXLn4Cy5V_p4UAduWXnc0r8S05ijV8NCfmsEcJg-RRO8POkGykiC2mrn-XR8Nf8OF0fLp7Mhsb0_aqBoTOLdtB9V7IV49-JjWwX5gHl3HuXGOOhe4n_epumc8w8yDxYakWeaBFtEtaRmhFXK_yttexYOLP6Z1BBTL005hBGhO58qVW0cfgf_t5VWBpUnz3zqdC-GFegItqJQbKZ2pmfmXNz_AoJf2JmPtCzpJ4lG6QeSslvdFuwaCdYpDQPOvnMSIORwrAq_FL2m7qw

Use this to make authorized calls to the FestivalsApp Database Sidecar:

```bash
curl -H "Api-Key: TEST_API_KEY_001" -H "Authorization: Bearer <JWT>" --cert /opt/homebrew/etc/pki/issued/api-client.crt --key /opt/homebrew/etc/pki/private/api-client.key --cacert /opt/homebrew/etc/pki/ca.crt https://database-0.festivalsapp.home:22397/info
```
