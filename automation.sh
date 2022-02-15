#!/bin/bash

myname="pranshu"
s3_bucket="upgrad-pranshu"
timestamp=$(date '+%d%m%Y-%H%M%S')
sudo apt update -y
systemctl status apache2 >> /dev/null
if [ $? != 0 ]
then
        echo "Installing apache service"
        apt install apache2 -y
fi
systemctl enable apache2
systemctl is-active --quiet apache2
if [ $? != 0 ]
then
        systemctl restart apache2
fi
echo "Apache service is up and running"
cd /
cd var/log/apache2
tar -cf  $myname-httpd-logs-$timestamp.tar access.log error.log
file=$myname-httpd-logs-$timestamp.tar
cat /dev/null > access.log
cat /dev/null > error.log
cp $file /tmp
cd /
cd /tmp
filetype=$(ls -Art | tail -n 1 | cut -d "." -f 2)
size=$(ls -Arthl | tail -n 1 |cut -d " " -f 6)
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

