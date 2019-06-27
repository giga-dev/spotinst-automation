#!/bin/bash
function logger {
    echo "$@" >> /data/shutdown.log
}

while true; do
    if [[ -z $(curl -Is http://169.254.169.254/latest/meta-data/spot/instance-action | head -1 | grep 404 | cut -d ' ' -f 2) ]]; then
        logger "Running shutdown hook."
        sleep 1m
        supervisorctl stop all
        docker stop $(docker ps -aq)
        break
    else
        sleep 5s
    fi
done