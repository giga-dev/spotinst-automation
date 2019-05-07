#!/bin/bash

yum install python-pip -y
pip install supervisor

mkdir -p /etc/supervisord/conf.d
echo_supervisord_conf > /etc/supervisord.conf
echo "[include]" >> /etc/supervisord.conf
echo "files = /etc/supervisord/conf.d/*.conf" >> /etc/supervisord.conf

cp supervisord.service /usr/lib/systemd/system/supervisord.service

systemctl start supervisord
systemctl enable supervisord