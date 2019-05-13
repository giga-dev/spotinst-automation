#!/bin/bash
set -xe
DIRNAME=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`


function run_command_ec2_user {
    su ec2-user -c "$@"
}

function prepare_jenkins {

	if [ ! -e "/data/jenkins/xap-jenkins" ]; then
	    function init_jenkins {
            mkdir /data/jenkins
            cd /data/jenkins
            git clone https://github.com/Gigaspaces/xap-jenkins.git
            cd xap-jenkins
            git checkout spotinst
            cd jenkins-docker
            ./build.sh
		}

		export -f init_jenkins
		run_command_ec2_user init_jenkins

		cp ${DIRNAME}/../master-node/supervisor_jenkins.conf /etc/supervisord.d/

		supervisorctl reread
		supervisorctl reload
	fi
}

function prepare_newman {
	if [ ! -e "/data/newman/newman" ]; then

	    function init_newman {
            mkdir /data/newman
            cd /data/newman
            git clone https://github.com/giga-dev/newman.git
            cd newman
            git checkout spotinst
            cd docker
            `pwd`/docker-build.sh
            `pwd`/server-build.sh
        }
        export -f init_newman
        run_command_ec2_user init_newman

		cp ${DIRNAME}/../master-node/supervisor_newman.conf /etc/supervisord.d/

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

chown ec2-user:ec2-user /data
prepare_jenkins
prepare_newman

hostnamectl set-hostname automation-master
#reboot