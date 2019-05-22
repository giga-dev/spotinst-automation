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
            echo "export NEWMAN_AGENT_GROUPNAME=\"${NEWMAN_AGENT_GROUPNAME}\"" >> ../newman-agent/bin/env.sh

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
		systemctl start docker
		systemctl enable docker
        usermod -a -G docker ec2-user
	fi
}

yum update -y
yum install nano -y

install_docker
${DIRNAME}/install_java.sh
${DIRNAME}/../supervisor/install.sh

chown ec2-user:ec2-user /data
prepare_newman
