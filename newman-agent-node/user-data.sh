#!/bin/bash
set -xe
DIRNAME=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`


function run_command_ec2_user {
    su - ec2-user -c "$@"
}

function prepare_newman {
	if [ ! -e "/data/newman/newman" ]; then
		mkdir /data/newman
		cd /data/newman
		git clone https://github.com/giga-dev/newman.git
		cd newman
		git checkout spotinst
		cd docker
		run_command_ec2_user `pwd`/docker-build.sh
		run_command_ec2_user `pwd`/agent-build.sh

        echo "export NEWMAN_SERVER_HOST=newman-server" >> ../newman-agent/bin/env.sh
		cp ${DIRNAME}/../newman-agent-node/supervisor_newman.conf /etc/supervisord.d/

		supervisorctl reread
		supervisorctl reload
	fi
}

function install_docker {
	command -v docker
	if [ "$?" == "1" ]; then
		amazon-linux-extras install docker -y
		service docker start
		usermod -a -G docker ec2-user
	fi
}

yum update -y
yum install nano -y

install_docker
../supervisor/install.sh

prepare_newman