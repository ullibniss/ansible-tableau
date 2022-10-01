#!/bin/bash
# Driver installation and other artifact installation script

# Download PostgreSQL driver
mkdir -p /opt/tableau/tableau_driver/jdbc
curl -L -o /opt/tableau/tableau_driver/jdbc/postgresql-42.2.22.jar https://downloads.tableau.com/drivers/linux/postgresql/postgresql-42.2.22.jar 

# Download && install MySQL driver
curl -L -o mysql-connector-odbc-8.0.26-linux-glibc2.12-x86-64bit.tar.gz https://downloads.mysql.com/archives/get/p/10/file/mysql-connector-odbc-8.0.26-linux-glibc2.12-x86-64bit.tar.gz 
tar xvf mysql-connector-odbc-8.0.26-linux-glibc2.12-x86-64bit.tar.gz
cp mysql-connector-odbc-8.0.26-linux-glibc2.12-x86-64bit/bin/* /usr/local/bin
cp mysql-connector-odbc-8.0.26-linux-glibc2.12-x86-64bit/lib/* /usr/local/lib
yum install -y unixODBC openssl11

myodbc-installer -a -d -n "MySQL ODBC 8.0 Driver" -t "Driver=/usr/local/lib/libmyodbc8w.so"

# Cleanup after installing
rm -rf mysql-connector-odbc-8.0.26-linux-glibc2.12-x86-64bit.tar.gz
rm -rf mysql-connector-odbc-8.0.26-linux-glibc2.12-x86-64bit
