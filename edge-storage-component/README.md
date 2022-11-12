# Edge Storage Component

This is the Edge Storage component of the ACCORDION platform (ACES for short). It aims to provide storage capabilities inside the edge mini-clouds, utilizing the edge resources and optimizing the data transfer, caching and storage.

# Installation

## Single node cluster

The file singleClusterInstallScript.sh is a self-contained installation script for a single node cluster deployment.

## Multi-node cluster

For multinode clusters the acesServerDeploy.sh should be used. 
In order for it to be used a manual configuration need to be carried out before it's execution.
The configuration includes:
* Defining the data path for data storage in the storage workers.
* Set the data path in the aces config file `acesConfig.conf`.
* Add the label `aces-worker=true` to all storage worker nodes.

## License
ACES is published under the [AGPL V3 licence](https://www.gnu.org/licenses/agpl-3.0.txt).