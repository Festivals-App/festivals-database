# Operation

The `operation` directory contains all configuration templates and scripts to install and run the festvials-database.

* `backup.sh` script to backup the database to run periodically from a cron job
* `festivals_mysql_template.cnf` custom config template for MySQL SSL configuration (unused atm)
* `install.sh` script to install the festivals-database-node and the database on a VM
* `restore_database.sh` script to restore the database from compressed backup created with the backup script
* `secure-mysql.sh` script to secure the intitial mysql installation
* `service_template.service` festivals database node unit file for `systemctl`
* `ufw_app_profile` firewall app profile file for `ufw`
* `update_node.sh` script to update the festivals-database-node

## Deployment

Follow the [**deployment guide**](DEPLOYMENT.md) for deploying the festivals-database inside a virtual machine or the [**local deployment guide**](./local/README.md) for running it on your macOS developer machine.
