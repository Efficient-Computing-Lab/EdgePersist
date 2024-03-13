# EdgePersist

[EdgePersist](https://antonismakris.github.io/edgestorageenabler/) is a package of components that enable edge storage for IoT and smart device edge networks.

It contains three main components:
* **Edge Storage Component**: the core component that provides the edge storage capabilities based on MinIO and K8s 
*  **Edge Localized Docker Registry**: the localized docker registry that uses the edge storage component as a back end for real-time and proactive docker image migration and replication.
* **Edge Registry Sync Daemon**: a daemon process that syncs the localized registry to one or more remote ones based on a Kafka message bus.

Each folder includes an individual readme file containing comprehensive installation and usage instructions for its corresponding component.