#!/bin/bash
function logger {
    local currDate=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[${currDate}] $@" >> /data/shutdown.log
}

logger "Starting monitoring for spot termination"
aws configure set region us-east-2

while true; do
    res=$(curl -Is http://169.254.169.254/latest/meta-data/spot/instance-action)
    if [[ -z $(echo $res | head -1 | grep 404 | cut -d ' ' -f 2) ]]; then
        logger "Detected shutdown event for the instance, running shutdown hook"
        logger "Message was: $res"
	aws sns publish --message="Detected shutdown event for the instance, running shutdown hook. Message was: $res" --topic-arn "arn:aws:sns:us-east-2:573366771204:Spotinst-instances" --subject "Groot is going down $(date +'%Y-%m-%d %H:%M:%S')"
        logger "Email was sent"
        sleep 1m
	#Stop every supervisor service except the spot_termination_handler (otherwise it won't be able to detect a false alarm"
        supervisorctl stop $(supervisorctl status | grep -v "spot_termination_handler" | awk '{ print $1 }')
        docker stop $(docker ps -aq)
        logger "Shutdown was completed"
        sleep 20m
        logger "Apparently it was a false alarm, restarting all services"
	aws sns publish --message="Spot wasn't terminated within 20 mins, apparently a false alarm. Restarting all services.." --topic-arn "arn:aws:sns:us-east-2:573366771204:Spotinst-instances" --subject "Groot is going down $(date +'%Y-%m-%d %H:%M:%S')"
        supervisorctl start all
        sleep 1m
    else
        sleep 10s
    fi
done

logger "Stopped"
