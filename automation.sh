


#!/bin/bash

myname="pranshu"
#MYNAME IS PRANSHU PALIWAL
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
if [[ ! -f "/var/www/html/inventory.html" ]]
then
        echo "Creating inventory.html at /var/www/html"
        cd /var/www/html
        echo -e "<br>&ensp;LogType&ensp;&ensp;&ensp;DateCreated&ensp;&ensp;&ensp;&ensp;&ensp;Type&ensp;&ensp;Size<br> " > inventory.html
fi
cd /var/www/html

echo -e "<br>&ensp;httpd-logs&ensp;&ensp;$timestamp&ensp;&ensp;$filetype&ensp;&ensp;$size<br>" >> inventory.html
#cd /tmp
#rm *.tar
cd /
if [[ ! -f "/etc/cron.d/automation" ]]
then
        echo "Creating a automation file at cd /etc/cron.d"
        cd /tmp
        echo "0 12 */2 * * root cd /Automation_Project && ./automation.sh && cd /" > automation
        mv automation /etc/cron.d
fi

