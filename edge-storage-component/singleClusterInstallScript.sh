#!/bin/bash
#	This file is part of Edge Storage Enabler.
#
#    Edge Storage Enabler is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Edge Storage Enabler is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Edge Storage Enabler.  If not, see https://www.gnu.org/licenses/.

# Define the file path for the data storage
edgeDataPath=/data/test

# Create the directory if it does not exists
sudo mkdir -p $edgeDataPath

# Define the directory in config file
sudo sed -i 's;"/media/minio_storage/minio";"'$edgeDataPath'";g' "./edgeConfig.conf"

# Get the first node name from K3s
edgeNode=$(sudo k3s kubectl get nodes | head -n 2 | tail -n 1 | cut -d ' ' -f 1)

# Label the node as a storage-worker
sudo k3s kubectl label node $edgeNode edge-storage-worker=true --overwrite
sudo k3s kubectl label node $edgeNode edge-storage-server=true --overwrite

# Make the deployment script executable
sudo chmod +x ./edgeServerDeploy.sh

# Deploy the edge storage in K3s
sudo ./edgeServerDeploy.sh