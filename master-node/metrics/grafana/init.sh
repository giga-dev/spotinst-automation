#!/bin/bash

DIRNAME=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
DATADIR=/data/metrics/grafana

if [ ! -e "${DATADIR}" ]; then
  mkdir -p ${DATADIR}/dashboards
  mkdir -p ${DATADIR}/logs
  mkdir -p ${DATADIR}/plugins
fi

cp ${DIRNAME}/supervisor_grafana.conf /etc/supervisord.d/
