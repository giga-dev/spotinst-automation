#!/bin/bash
set -x
DIRNAME=`cd $(dirname ${BASH_SOURCE[0]}) && pwd`
GROOT_MAIL_SUBJECT="Groot instance has started $(date +'%Y-%m-%d %H:%M:%S')"
STARTTIME=$(date +%s)

aws configure set region us-east-2

aws sns publish --message="Groot instance has started, running user-data.sh script" --topic-arn "arn:aws:sns:us-east-2:573366771204:Spotinst-instances" --subject "${GROOT_MAIL_SUBJECT}"

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
            cd jenkins-docker
            ./build.sh
		}

		export -f init_jenkins
    else
         function init_jenkins {
            cd /data/jenkins/xap-jenkins/jenkins-docker
            ./build.sh
		}
		export -f init_jenkins
    fi

    run_command_ec2_user init_jenkins

	cp ${DIRNAME}/supervisor_jenkins.conf /etc/supervisord.d/

	supervisorctl reread
	supervisorctl reload

}

function prepare_newman {
	if [ ! -e "/data/newman/newman" ]; then

	    function init_newman {
            mkdir /data/newman
            cd /data/newman
            git clone https://github.com/giga-dev/newman.git
            cd newman/docker
            `pwd`/docker-build.sh
            `pwd`/server-build.sh
        }
        export -f init_newman
    else
        function init_newman {
            cd /data/newman/newman/docker
            `pwd`/docker-build.sh
        }
        export -f init_newman
	fi

    run_command_ec2_user init_newman
	cp ${DIRNAME}/supervisor_newman.conf /etc/supervisord.d/

	supervisorctl reread
	supervisorctl reload
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

function install_shutdown_handler {
    cp ${DIRNAME}/spot-termination-handler.sh /etc/supervisord.d/
    cp ${DIRNAME}/supervisor_spot.conf /etc/supervisord.d/

	supervisorctl reread
	supervisorctl reload
}

yum update -y
yum install nano -y

install_docker
../supervisor/install.sh
install_shutdown_handler

chown ec2-user:ec2-user /data
prepare_jenkins
prepare_newman

hostnamectl set-hostname groot

rm -f /etc/motd
cp ${DIRNAME}/loginmsg /etc/motd

ENDTIME=$(date +%s)
echo "user-data took $(($ENDTIME - $STARTTIME)) to be completed..."
aws sns publish --message="user-data.sh script has finished, system is up and running, took $(($ENDTIME - $STARTTIME))" --topic-arn "arn:aws:sns:us-east-2:573366771204:Spotinst-instances" --subject "${GROOT_MAIL_SUBJECT}"
#reboot
