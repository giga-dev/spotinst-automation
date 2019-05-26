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
            local envFile=../newman-agent/bin/env.sh
            echo "export NEWMAN_SERVER_HOST=newman-server" >> ${envFile}
            echo "export NEWMAN_AGENT_GROUPNAME=\"${NEWMAN_AGENT_GROUPNAME}\"" >> ${envFile}
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

function install_maven {
    command -v mvn
    if [[ "$?" == "1" ]]; then
        echo "Installing maven"

        local installDir="/opt/apache-maven-3.3.9"
        wget --no-verbose -O /tmp/apache-maven-3.3.9.tar.gz \
            http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

        # stop building if md5sum does not match
        echo "516923b3955b6035ba6b0a5b031fbd8b  /tmp/apache-maven-3.3.9.tar.gz" | \
            md5sum -c

        mkdir -p ${installDir}

        tar xzf /tmp/apache-maven-3.3.9.tar.gz --strip-components=1 \
            -C ${installDir}

        ln -s ${installDir}/bin/mvn /usr/local/bin
        rm -f /tmp/apache-maven-3.3.9.tar.gz
    fi
}

yum update -y
yum install nano -y

install_docker
install_maven
${DIRNAME}/install_java.sh
${DIRNAME}/../supervisor/install.sh

chown ec2-user:ec2-user /data
prepare_newman
