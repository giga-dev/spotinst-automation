#!/bin/bash


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

    pushd ${tmpFolder}
    download ${source} ${tmpFolder}
    tar -zxvf ${filename}
    rm -rf ${filename}
    mv $(ls) ${javaLocations}/

    ls -1 ${javaLocations}
    popd

    rm -rf ${tmpFolder}
}

function setDefaultJava {
    echo "export PATH=/usr/java/jdk1.8.0_45/bin:\$PATH" >> /etc/profile
    echo "export JAVA_HOME=/usr/java/jdk1.8.0_45" >> /etc/profile
    source /etc/profile
}

install_java https://${STORAGE_SERVER}/javas/jdk-8u45-linux-x64.tar.gz

install_java https://${STORAGE_SERVER}/javas/jdk-9.0.4_linux-x64_bin.tar.gz

install_java https://${STORAGE_SERVER}/javas/openjdk-11.0.1_linux-x64_bin.tar.gz

install_java https://${STORAGE_SERVER}/javas/openjdk-17.0.1_linux-x64_bin.tar.gz

setDefaultJava
