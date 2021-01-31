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

docker stop influxdb influxdb-init
docker rm influxdb influxdb-init

docker run -p 8086:8086 --network metrics --name=influxdb-init --rm \
  -e INFLUXDB_ADMIN_USER=${INFLUX_ADMIN_USER} \
  -e INFLUXDB_ADMIN_PASSWORD=${INFLUX_ADMIN_PASSWORD} \
  -v ${DATADIR}:/var/lib/influxdb:rw \
  -v ${DIRNAME}/entrypoint-init:/docker-entrypoint-initdb.d \
  influxdb:${INFLUX_VERSION} /init-influxdb.sh

docker run ${MODE} -p 8086:8086 --network metrics --name=influxdb --rm \
  -e INFLUXDB_ADMIN_USER=${INFLUX_ADMIN_USER} \
  -e INFLUXDB_ADMIN_PASSWORD=${INFLUX_ADMIN_PASSWORD} \
  -v ${DATADIR}:/var/lib/influxdb:rw \
  influxdb:${INFLUX_VERSION}

