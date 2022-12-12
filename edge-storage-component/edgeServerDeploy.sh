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

bucketName=$(cat ./edgeConfig.conf | grep BUCKET_NAME | cut -d':' -f 2 | sed -r 's/"//g')	
edgeKey=$(cat ./edgeConfig.conf | grep access-key | cut -d':' -f 2 | sed -r 's/"//g')
edgeKeyDecoded=$(cat ./edgeConfig.conf | grep access-key | cut -d':' -f 2 | sed -r 's/"//g'| base64 --decode)
edgeSecret=$(cat ./edgeConfig.conf | grep secret-key | cut -d':' -f 2 | sed -r 's/"//g')
edgeSecretDecoded=$(cat ./edgeConfig.conf | grep secret-key | cut -d':' -f 2 | sed -r 's/"//g'| base64 --decode)
dataPath=$(cat ./edgeConfig.conf | grep data-path | cut -d':' -f 2 | sed -r 's;";;g')
edgeServers=$(cat ./edgeConfig.conf | grep edgeStorageServers | cut -d':' -f 2 | sed -r 's;";;g')
singleNodeArch=$(k3s kubectl get nodes -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)
masterNodeArch=$(k3s kubectl get nodes -l edge-storage-server="true" -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)
workerNodeArch=$(k3s kubectl get nodes -l edge-storage-worker="true" -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)

sed -e 's/{{bucketName}}/'$bucketName'/g;s/{{edgeKey}}/'$edgeKey'/g;s/{{edgeSecret}}/'$edgeSecret'/g;s?{{dataPath}}?'$dataPath'?g;s?{{edgeServers}}?'$edgeServers'?g' "./edgeServerDeployment.yaml" | k3s kubectl apply -f -
k3s kubectl wait --for=condition=ready pod edgestorage-0 -n edgestorage --timeout=120s
edge_api="http://$(sudo k3s kubectl describe pod edgestorage-0 --namespace edgestorage | grep Node: | cut -d'/' -f 2):9010"
edge_endpoint="http://$(sudo k3s kubectl describe pod edgestorage-0 --namespace edgestorage | grep Node: | cut -d'/' -f 2):9011"
cat <<EOF | k3s kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: edge-admin-create-bucket
  namespace: edgestorage
  labels:
    app: edgestorage
spec:
  completions: 1
  template:
    spec:
      containers:
      - name: edge-admin
        image: minio/mc
        env:
        - name: MINIO_ACCESS_POINT
          value: $edge_api
        - name: MINIO_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: edge-keys
              key: access-key
        - name: MINIO_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: edge-keys
              key: secret-key
        command: ["/bin/sh", "-c"]
        args: ["mc alias set minio \$MINIO_ACCESS_POINT \$MINIO_ACCESS_KEY \$MINIO_SECRET_KEY --api S3v4; mc mb minio/$bucketName;"]
      restartPolicy: Never
  backoffLimit: 2
EOF
if [[ $workerNodeArch == *"amd"* ]]; then
k3s kubectl apply -f dlf.yaml
k3s kubectl wait --for=condition=ready pods --all -n dlf --timeout=120s
cat <<EOF | k3s kubectl apply -f -
apiVersion: com.ie.ibm.hpsys/v1alpha1
kind: Dataset
metadata:
  name: edge-data
spec:
  local:
    type: "COS"
    accessKeyID: "$edgeKeyDecoded"
    secretAccessKey: "$edgeSecretDecoded"
    endpoint: "$edge_api"
    bucket: "$bucketName"
    readonly: "false"
EOF
echo "Created the pvc named edge-data."
fi

echo "Created the bucket $bucketName"
echo "Created the access point $edge_endpoint"
echo "Access key: $edgeKeyDecoded"
echo "Secret key: $edgeSecretDecoded"