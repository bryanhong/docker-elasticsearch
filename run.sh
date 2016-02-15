#!/bin/bash

source vars

#If there is a locally built image present, prefer that over the
#one in the registry, we're going to assume you're working on changes
#to the image.

if [[ ! -f builds ]]; then
  LATESTIMAGE=${REPO_NAME}/${APP_NAME}:latest
else
  LATESTIMAGE=`tail -1 builds | awk '{print $8}'`
fi
echo
echo "Starting $APP_NAME..."
echo
echo -n "Container ID: "
docker run                                                 \
  --detach=true                                            \
  --log-driver=syslog                                      \
  --name="${APP_NAME}"                                     \
  --restart=always                                         \
  --publish ${DOCKER_HOST_API_PORT}:9200                   \
  --volume ${ELASTICSEARCH_DATADIR}:/var/lib/elasticsearch \
  --env CLUSTER_NAME=${CLUSTER_NAME}                       \
  --env CLUSTER_NODES="${CLUSTER_NODES}"                   \
  --env DOCKER_HOST_IP=${DOCKER_HOST_IP}                   \
  --env NODE_NAME=${NODE_NAME}                             \
  --publish ${DOCKER_HOST_TRANSPORT_PORT}:9300             \
  ${LATESTIMAGE}
# Other useful options
# -p DOCKERHOST_PORT:CONTAINER_PORT \
# -e "ENVIRONMENT_VARIABLE_NAME=VALUE" \
# -v /DOCKERHOST/PATH:/CONTAINER/PATH \
