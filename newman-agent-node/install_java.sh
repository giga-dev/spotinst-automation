#!/bin/bash

STORAGE_SERVER="gs-storage-server.s3.amazonaws.com"

function download {
    local url=$1
    local target=$2

    wget ${url} -P ${target}
}

function install_java {
    local javaLocations=/usr/java
    local source=$1
    local filename=$(basename ${source})
    local tmpFolder=$(mktemp -d)

    sudo mkdir -p ${javaLocations}
    pushd ${tmpFolder}
    download ${source} ${tmpFolder}
    tar xfvz ${filename}
    rm -rf ${filename}
    sudo mv $(ls) ${javaLocations}/

    ls -1 ${javaLocations}
    popd

    rm -rf ${tmpFolder}
}

function setDefaultJava {
    echo "export PATH=/usr/java/jdk1.8.0_45/bin:\$PATH" | sudo tee -a /etc/profile
    echo "export JAVA_HOME=/usr/java/jdk1.8.0_45" | sudo tee -a /etc/profile
    source /etc/profile
}

install_java https://${STORAGE_SERVER}/jdk/jdk-8u45-linux-x64.tar.gz

install_java https://${STORAGE_SERVER}/jdk/jdk-9.0.4_linux-x64_bin.tar.gz

install_java https://${STORAGE_SERVER}/jdk/jdk-11.0.18_linux-x64_bin.tar.gz

install_java https://${STORAGE_SERVER}/jdk/openjdk-17_35_linux-x64_bin.tar.gz

setDefaultJava