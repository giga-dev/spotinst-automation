#!/bin/bash
function logger {
    local currDate=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[${currDate}] $@" >> /data/shutdown.log
}

logger "Starting monitoring for spot termination"

while true; do
    if [[ -z $(curl -Is http://169.254.169.254/latest/meta-data/spot/instance-action | head -1 | grep 404 | cut -d ' ' -f 2) ]]; then
        logger "Detected shutdown event for the instance, running shutdown hook"
        logger "Message was: $(curl -Is http://169.254.169.254/latest/meta-data/spot/instance-action)"
        sleep 1m
        supervisorctl stop all
        docker stop $(docker ps -aq)
        logger "Shutdown was completed"
        break
    else
        sleep 10s
    fi
done

logger "Stopped"
