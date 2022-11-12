#!/bin/bash
#	 This file is part of ACCORDION Edge Storage Component (ACES).
#
#    ACCORDION Edge Storage Component (ACES) is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    ACCORDION Edge Storage Component (ACES) is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with ACCORDION Edge Storage Component (ACES).  If not, see https://www.gnu.org/licenses/.

# Define the file path for the data storage
acesDataPath=/data/test

# Create the directory if it does not exists
sudo mkdir -p $acesDataPath

# Define the directory in config file
sudo sed -i 's;"/media/minio_storage/minio";"'$acesDataPath'";g' "./acesConfig.conf"

# Get the first node name from K3s
acesNode=$(sudo k3s kubectl get nodes | head -n 2 | tail -n 1 | cut -d ' ' -f 1)

# Label the node as a storage-worker
sudo k3s kubectl label node $acesNode aces-worker=true

# Make the deployment script executable
sudo chmod +x ./acesServerDeploy.sh

# Deploy the edge storage in K3s
sudo ./acesServerDeploy.sh