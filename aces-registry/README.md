# ACES Registry

## Description
ACES registry aims at providing a localized Docker registry using ACES as its file storage backend.
It is using Kubernetes containerization in order to provide its services, creating a new pod in the ACES namespace that is able to connect to the Minio storage backend.
In addition, ACES registry creates a set of secrets that allows the secure communication between the registry and its clients using the HTTPS protocol and a basic authentication scheme.

## Setup
In order to setup ACES registry an active ACES deployment must be present in the targeted minicloud.
Then the files of ACES registry must be downloaded from the gitlab page.
After that the file registry_setup.sh must be executed.
After the successfull execution of registry_setup.sh the commands `update-ca-certificates` and `systemctl restart containerd` should be executed on each client in order to ensure that the SSL certificates are updated.

## Usage
The script registry_setup.sh should output simple testing instructions as well as the registry URL and credentials if it is password protected. 
In order to use the registry through Kubernetes deployment files the endpoint must be used in the image URL of the specified containers and the image must be present in ACES registry.
In order to list the available images the [docker registry API v2](https://docs.docker.com/registry/spec/api/) can be used, more specifically the url `/v2/_catalog`.

## License
ACES registry is published under the [AGPL V3 licence](https://www.gnu.org/licenses/agpl-3.0.txt).
