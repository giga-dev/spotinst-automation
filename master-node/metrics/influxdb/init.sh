#!/bin/bash

DIRNAME=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
DATADIR=/data/metrics/influxdb

if [ ! -e "${DATADIR}" ]; then
  mkdir -p ${DATADIR}
fi

cp ${DIRNAME}/supervisor_influxdb.conf /etc/supervisord.d/

