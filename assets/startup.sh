#! /bin/bash

function LogToDevNull () {
  # Prevent logs from bloating the container, logs should be going to the Docker host syslog already
  ln -sf /dev/null /var/log/elasticsearch/${CLUSTER_NAME}.log
  ln -sf /dev/null /var/log/elasticsearch/${CLUSTER_NAME}_deprecation.log
  ln -sf /dev/null /var/log/elasticsearch/${CLUSTER_NAME}_index_indexing_slowlog.log
  ln -sf /dev/null /var/log/elasticsearch/${CLUSTER_NAME}_index_search_slowlog.log
}

# Backup default Elasticsearch config for reference
cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml-dist

# Create Elasticsearch config
cat << EOF > /etc/elasticsearch/elasticsearch.yml
network.host: 0.0.0.0
node.name: ${NODE_NAME}
EOF

# Add Cluster peers and IP to advertise to peers if configured
if [[ -n "${CLUSTER_NODES}" ]] && [[ -n "${DOCKER_HOST_IP}" ]] && [[ -n "${CLUSTER_NAME}" ]]; then
  echo "network.publish_host: ${DOCKER_HOST_IP}" >> /etc/elasticsearch/elasticsearch.yml
  echo "discovery.zen.ping.unicast.hosts: ${CLUSTER_NODES}" >> /etc/elasticsearch/elasticsearch.yml
  echo "cluster.name: ${CLUSTER_NAME}" >> /etc/elasticsearch/elasticsearch.yml
  LogToDevNull
else
  # Since we didn't set cluster.name above, it defaults to "elasticsearch"
  CLUSTER_NAME=elasticsearch
  LogToDevNull
fi

# Set correct permissions to data directory
chown elasticsearch /var/lib/elasticsearch

# Start Supervisor
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
