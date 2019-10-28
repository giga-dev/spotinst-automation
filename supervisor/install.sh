#!/bin/bash
DIRNAME=$(dirname ${BASH_SOURCE[0]})

if [ ! -e "/etc/supervisord/" ]; then
	yum install python-pip -y
	pip install supervisor==4.0.4

	mkdir /data/supervisordFiles
	
	mkdir -p /etc/supervisord.d
	cp ${DIRNAME}/supervisord.conf /etc/supervisord.conf


	cp ${DIRNAME}/supervisord.service /usr/lib/systemd/system/supervisord.service

	groupadd supervisor
	usermod -a ec2-user -G supervisor
	systemctl start supervisord
	systemctl enable supervisord
fi
