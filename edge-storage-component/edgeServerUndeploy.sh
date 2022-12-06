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

k3s kubectl delete Dataset edge-data
k3s kubectl delete -f dlf.yaml
k3s kubectl delete Job edge-admin-create-bucket

bucketName=$(cat ./edgeConfig.conf | grep BUCKET_NAME | cut -d':' -f 2 | sed -r 's/"//g')	
edgeKey=$(cat ./edgeConfig.conf | grep access-key | cut -d':' -f 2 | sed -r 's/"//g')
edgeKeyDecoded=$(cat ./edgeConfig.conf | grep access-key | cut -d':' -f 2 | sed -r 's/"//g'| base64 --decode)
edgeSecret=$(cat ./edgeConfig.conf | grep secret-key | cut -d':' -f 2 | sed -r 's/"//g')
edgeSecretDecoded=$(cat ./edgeConfig.conf | grep secret-key | cut -d':' -f 2 | sed -r 's/"//g'| base64 --decode)
dataPath=$(cat ./edgeConfig.conf | grep data-path | cut -d':' -f 2 | sed -r 's;";;g')
edgeServers=$(cat ./edgeConfig.conf | grep edgeServers | cut -d':' -f 2 | sed -r 's;";;g')
singleNodeArch=$(k3s kubectl get nodes -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)
masterNodeArch=$(k3s kubectl get nodes -l edge-storage-server="true" -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)
workerNodeArch=$(k3s kubectl get nodes -l edge-storage-worker="true" -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)

sed -e 's/{{bucketName}}/'$bucketName'/g;s/{{edgeKey}}/'$edgeKey'/g;s/{{edgeSecret}}/'$edgeSecret'/g;s?{{dataPath}}?'$dataPath'?g;s?{{edgeServers}}?'$edgeServers'?g' "./edgeServerDeployment.yaml" | k3s kubectl delete -f -