#!/bin/bash
set -x
DIRNAME=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`

function prepare_jenkins {

	if [ ! -e "/data/jenkins/xap-jenkins" ]; then
		mkdir /data/jenkins
		cd /data/jenkins
		git clone https://github.com/Gigaspaces/xap-jenkins.git
		cd xap-jenkins
		git checkout spotinst
		cd jenkins-docker
		./build.sh

		cp ${DIRNAME}/../master-node/supervisor_jenkins.conf /etc/supervisord.d/

		supervisorctl reread
		supervisorctl reload
	fi
}

function prepare_newman {
	if [ ! -e "/data/newman/newman" ]; then
		mkdir /data/newman
		cd /data/newman
		git clone https://github.com/giga-dev/newman.git
		cd newman
		git checkout spotinst
		echo "export COMPONENT=server" > /data/newman/env.sh
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

prepare_jenkins
prepare_newman