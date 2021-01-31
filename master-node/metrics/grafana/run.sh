#!/bin/bash

DIRNAME=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${DIRNAME}/env.sh
MODE="-d"
if [[ -n "$1" ]]; then
  if [[ "$1" == "-iii" ]]; then
    MODE=""
  else
    MODE="$1"
  fi
fi

docker run ${MODE} --name=grafana -p 3000:3000 --user $(id -u) --network=metrics --rm \
  -v ${DATADIR}:/var/lib/grafana:rw \
  -v ${DIRNAME}/provisioning:/etc/grafana/provisioning:rw \
  -v ${DIRNAME}/dashboards:/var/lib/grafana/dashboards:rw \
  -e GF_AUTH_ANONYMOUS_ENABLED=true \
  -e GF_PATHS_PROVISIONING=/etc/grafana/provisioning \
  -e GF_PATHS_DATA=/var/lib/grafana \
  -e GF_PATHS_PLUGINS=/var/lib/grafana/plugins \
  -e GF_PATHS_LOGS=/var/lib/grafana/logs \
  -e GF_LOG_LEVEL=DEBUG \
  -e GF_LOG_MODE=console grafana/grafana:${GRAFANA_VERSION}
