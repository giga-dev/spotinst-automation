#!/bin/bash
set -x
sudo wget -r --no-parent -A 'epel-release-*.rpm' https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/

sudo rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-*.rpm

sudo yum-config-manager --enable epel*

sudo yum repolist all


sudo yum install -y certbot python2-certbot-apache




sudo certbot certonly --standalone -d groot.gspaces.com --config-dir=/data/certificates/ --agree-tos -n --keep --email yohana.khoury@gigaspaces.com

sudo chown -R ec2-user:ec2-user /data/certificates/
echo "0 6 * * sat root certbot renew --config-dir=/data/certificates/ -q && sleep 5m && supervisorctl restart newmanserver" | sudo tee -a /etc/crontab > /dev/null

sudo ./newman-cert.sh
