#!/bin/bash
set -x
DIRNAME=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`


function run_command_ec2_user {
    su ec2-user -c "$@"
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
            `pwd`/agent-build.sh
            echo "export NEWMAN_SERVER_HOST=newman-server" >> ../newman-agent/bin/env.sh

        }
        export -f init_newman
        run_command_ec2_user init_newman

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

function install_java {
    command -v java
    if [[ "$?" == "1" ]]; then
        wget http://hercules.gspaces.com/javas/jdk-8u45-linux-x64.tar.gz -O /tmp/jdk-8u45-linux-x64.tar.gz
        cd /tmp
        tar -zxvf jdk-8u45-linux-x64.tar.gz
        mkdir -p /usr/lib/jvm/
        mv jdk1.8.0_45 /usr/lib/jvm/java-8-oracle
        echo "export PATH=/usr/lib/jvm/java-8-oracle/bin:\$PATH" >> /etc/profile
        rm -rf /tmp/jdk-8u45-linux-x64.tar.gz
        source /etc/profile
    fi

}

yum update -y
yum install nano -y

install_docker
install_java
${DIRNAME}/../supervisor/install.sh

chown ec2-user:ec2-user /data
prepare_newman