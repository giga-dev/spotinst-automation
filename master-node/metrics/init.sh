#!/bin/bash

DIRNAME=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
BASE_DATADIR=/data/metrics

NETWORKS_CNT=$(docker network ls | grep metrics | wc -l)
if [ ${NETWORKS_CNT} -eq 0 ]; then
  docker network create metrics
fi

${DIRNAME}/influxdb/init.sh
${DIRNAME}/grafana/init.sh
chown -R ec2-user:ec2-user ${BASE_DATADIR}