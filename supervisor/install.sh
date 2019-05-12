#!/bin/bash
DIRNAME=$(dirname ${BASH_SOURCE[0]})

if [ ! -e "/etc/supervisord/" ]; then
	yum install python-pip -y
	pip install supervisor

	mkdir -p /etc/supervisord.d
	echo_supervisord_conf > /etc/supervisord.conf
	echo "[include]" >> /etc/supervisord.conf
	echo "files = /etc/supervisord.d/*.conf" >> /etc/supervisord.conf

	cp ${DIRNAME}/supervisord.service /usr/lib/systemd/system/supervisord.service

	systemctl start supervisord
	systemctl enable supervisord
fi