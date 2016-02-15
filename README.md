docker-elasticsearch
==

Elasticsearch in a container

>Elasticsearch is a highly scalable open-source full-text search and analytics engine. It allows you to store, search, and analyze big volumes of data quickly and in near real time. It is generally used as the underlying engine/technology that powers applications that have complex search features and requirements. [elastic.co](https://www.elastic.co/products/elasticsearch)

Quickstart
--

The following command will run elasticsearch, if you want to customize or build the container locally, skip to [Building the Container](#building-the-container) below

```
docker run                                                         \
  --detach=true                                                    \
  --log-driver=syslog                                              \
  --name="elasticsearch"                                           \
  --restart=always                                                 \
  --publish 9200:9200                                              \
  --volume /dockerhost/dir/for/data:/var/lib/elasticsearch         \
  --env CLUSTER_NAME=mycluster                                     \
  --env CLUSTER_NODES="["node2.example.com", "node3.example.com"]" \
  --env DOCKER_HOST_IP=ip.of.docker.host                           \
  --env NODE_NAME=node1                                            \
  --publish 9300:9300                                              \
  bryanhong/elasticsearch:latest
```

### Runtime flags explained

```
--detach=true
```  
run the container in the background  
```
--log-driver=syslog
```  
send logs to syslog on the Docker host  (requires Docker 1.6 or higher)  
```
--name="elasticsearch"
```  
name of the container  
```
--restart=always
```  
automatically start the container when the Docker daemon starts  
```
--publish 9200:9200
```  
Docker host port : mapped port in the container (Elasticsearch API)  
```
--volume /dockerhost/dir/for/data:/var/lib/elasticsearch
```  
path that elasticsearch will use to store its data on the Docker host : mapped path in the container

> The next few flags are for configuring an Elasticsearch cluster, they are optional, if you are setting up a single instance of Elasticsearch you can omit them entirely

```
--env CLUSTER_NAME=mycluster
```
name for your cluster, this should be set the same on other nodes
```
--env CLUSTER_NODES="["node2.example.com", "node3.example.com"]"
```
FQDN or IP addresses of the other members of the cluster, preserve the quoting in the example, it is important
```
--env DOCKER_HOST_IP=ip.of.docker.host
```
IP address that other cluster members can reach the Docker host on, specifically port 9300 for cluster communications
```
--env NODE_NAME=node1
```
short name for this Elasticsearch instance
```
--publish 9300:9300
```
Docker host port : mapped port in the container (Elasticsearch Transport, cluster members communicate over this port) 

Getting Status
--
Once your Elasticsearch container is up and running you should be able to point a web browser or run curl against port 9200 of your Docker host and get a response like this: 

```
$ curl http://node1.example.com:9200

{
  "name" : "node1",
  "cluster_name" : "mycluster",
  "version" : {
    "number" : "2.2.0",
    "build_hash" : "8ff36d139e16f8720f2947ef62c8167a888992fe",
    "build_timestamp" : "2016-01-27T13:32:39Z",
    "build_snapshot" : false,
    "lucene_version" : "5.4.1"
  },
  "tagline" : "You Know, for Search"
}
```
If you didn't build a cluster then you're on your own from here, checkout the Elasticsearch docs [here](https://www.elastic.co/guide/index.html).

If you built a cluster you can check health like this:

```
$ curl http://node1.example.com:9200/_cluster/health?pretty

{
  "cluster_name" : "mycluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 5,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```
You're on your own from here, checkout the Elasticsearch docs [here](https://www.elastic.co/guide/index.html).

Building the container
--

If you want to make modifications to the image or simply see how things work, check out this repository:

```
git clone https://github.com/bryanhong/docker-elasticsearch.git
```

### Commands and variables

* ```vars```: Variables for Docker registry, the application, and aptly repository data location
* ```build.sh```: Build the Docker image locally
* ```run.sh```: Starts the Docker container, it the image hasn't been built locally, it is fetched from the repository set in vars
* ```push.sh```: Pushes the latest locally built image to the repository set in vars
* ```shell.sh```: get a shell within the container

### How this image/container works

**Data**  
All of Elasticsearch's data is bind mounted outside the container to preserve it if the container is removed or rebuilt. Set the location for the bind mount in vars before starting the container.

**Networking**  
By default (in vars), Docker will map port 9200 on the Docker host to port 9200 within the container where Elasticsearch listens by default. You can change the external listening port in vars to map to any port you like.

**Security**  
* **API (port 9200)**  
Elasticsearch does not support authentication or authorization nor does it support the concept of a user. The data in Elasticsearch is readable/writable to anyone that has access to your Dockerhost. It'll be up to you to devise a way to grant/prevent access to the API.
* **Transport (port 9300)**  
Similarly to Elasticsearch's API, there is no authentication or authorization support for transport. Nodes will join a cluster if the CLUSTER_NAME matches and it can reach another Elasticsearch instance set in CLUSTER_NODES.

### Usage

#### Configure the container

1. Configure application specific variables in ```vars```

#### Build the image

1. Run ```./build.sh```

#### Start the container

1. Run ```./run.sh```
 
#### Pushing your image to the registry

If you're happy with your container and ready to share with others, push your image up to a [Docker registry](https://docs.docker.com/docker-hub/) and save any other changes you've made so the image can be easily changed or rebuilt in the future.

1. Authenticate to the Docker Registry ```docker login```
2. Run ```./push.sh```
3. Log into your Docker hub account and add a description, etc.

> NOTE: If your image will be used FROM other containers you might want to use ```./push.sh flatten``` to consolidate the AUFS layers into a single layer. Keep in mind, you may lose Dockerfile attributes when your image is flattened.
