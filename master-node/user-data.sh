#!/bin/bash

sudo yum install nano -y

mkdir /data/jenkins

cd /data/jenkins

git clone https://github.com/Gigaspaces/xap-jenkins.git

cd xap-jenkins

git checkout spotinst

cd jenkins-docker

./install-deps.sh