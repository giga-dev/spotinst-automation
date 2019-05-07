#!/bin/bash


function prepare_jenkins {
	
	mkdir /data/jenkins

	cd /data/jenkins

	git clone https://github.com/Gigaspaces/xap-jenkins.git

	cd xap-jenkins

	git checkout spotinst

	cd jenkins-docker

	./install-deps.sh
}

function prepare_newman {
	mkdir /data/newman

	cd /data/newman

	git clone https://github.com/giga-dev/newman.git

	cd newman

	git checkout spotinst

	echo "export COMPONENT=server" > /data/newman/env.sh
}

yum update -y
yum install nano git -y
pip install supervisor
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user


prepare_jenkins
prepare_newman