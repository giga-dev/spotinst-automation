#!/bin/bash



function install_java {
    local javaLocations=/opt
    local source=$1
    local filename=$(basename ${source})
    local tmpFolder=$(mktemp -d)

    pushd ${tmpFolder}
    wget ${source}
    tar -zxvf ${filename}
    rm -rf ${filename}
    mv $(ls) ${javaLocations}/

    ls -1 ${javaLocations}
    popd

    rm -rf ${tmpFolder}
}

install_java http://hercules.gspaces.com/javas/jdk-8u45-linux-x64.tar.gz

#install_java http://hercules.gspaces.com/javas/jdk-9.0.4_linux-x64_bin.tar.gz

#install_java http://hercules.gspaces.com/javas/openjdk-11.0.1_linux-x64_bin.tar.gz