#!/bin/bash
function logger {
    local currDate=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[${currDate}] $@" >> /data/shutdown.log
}

logger "Starting monitoring for spot termination"

while true; do
    res=$(curl -Is http://169.254.169.254/latest/meta-data/spot/instance-action)
    if [[ -z $(echo $res | head -1 | grep 404 | cut -d ' ' -f 2) ]]; then
        logger "Detected shutdown event for the instance, running shutdown hook"
        logger "Message was: $res"
	aws sns publish --message="Detected shutdown event for the instance, running shutdown hook. Message was: $res" --topic-arn "arn:aws:sns:us-east-2:573366771204:Spotinst-instances" --subject "Groot is going down $(date +'%Y-%m-%d %H:%M:%S')"
        sleep 1m
        supervisorctl stop all
        docker stop $(docker ps -aq)
        logger "Shutdown was completed"
        sleep 20m
        logger "Apparently it was a false alarm, restarting all services"
        supervisorctl start all
        sleep 1m
    else
        sleep 10s
    fi
done

logger "Stopped"
