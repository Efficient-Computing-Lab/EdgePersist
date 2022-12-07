# Edge Storage Component

This is the Edge Storage component. It aims to provide storage capabilities inside the edge mini-clouds, utilizing the edge resources and optimizing the data transfer, caching and storage.

# Installation

## Single node cluster

The file singleClusterInstallScript.sh is a self-contained installation script for a single node cluster deployment.

## Multi-node cluster

For multinode clusters the acesServerDeploy.sh should be used. 
In order for it to be used a manual configuration need to be carried out before it's execution.
The configuration includes:
* Defining the data path for data storage in the storage workers, which includes creating the necessary folders and setting the access rights in a way that Kubernetes is able to read and write into this path.
* Set the data path in the aces config file `edgeConfig.conf`.
* Add the label `edge-storage-worker=true` to all storage worker nodes.
* Add the label `edge-storage-master=true` to the storage master node.

## License
ACES is published under the [AGPL V3 licence](https://www.gnu.org/licenses/agpl-3.0.txt).
