#!/bin/bash

yum install python-pip -y
pip install supervisor

mkdir -p /etc/supervisord/conf.d
echo_supervisord_conf > /etc/supervisord/supervisord.conf
echo "files = conf.d/*.conf" >> /etc/supervisord/supervisord.conf

cp supervisord.service /usr/lib/systemd/system/supervisord.service

systemctl start supervisord
systemctl enable supervisord