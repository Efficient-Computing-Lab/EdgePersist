# Edge_Storage_Enabler

The Edge Storage Enabler is a package of components that enable edge storage for IoT and smart device edge networks.
It was build under the ACCORDION European founded project and it contains three components:
* edge storage component: the core component that provides the edge storage capabilities based on MinIO, K3s and Prometheus.
* aces registry: the localized docker registry that uses the edge storage component as a back end for real-time and proactive docker image migration and replication.
* aces registry sync daemon: a daemon process that syncs the localized registry to one or more remote ones based on a Kafka message bus.

Each folder contains a separate readme file that contains all the installation and ussage information about each component.