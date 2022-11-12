#!/bin/bash
#	This file is part of ACCORDION Edge Storage Component (ACES).
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

bucketName=$(cat ./acesConfig.conf | grep BUCKET_NAME | cut -d':' -f 2 | sed -r 's/"//g')	
acesKey=$(cat ./acesConfig.conf | grep access-key | cut -d':' -f 2 | sed -r 's/"//g')
acesKeyDecoded=$(cat ./acesConfig.conf | grep access-key | cut -d':' -f 2 | sed -r 's/"//g'| base64 --decode)
acesSecret=$(cat ./acesConfig.conf | grep secret-key | cut -d':' -f 2 | sed -r 's/"//g')
acesSecretDecoded=$(cat ./acesConfig.conf | grep secret-key | cut -d':' -f 2 | sed -r 's/"//g'| base64 --decode)
dataPath=$(cat ./acesConfig.conf | grep data-path | cut -d':' -f 2 | sed -r 's;";;g')
acesServers=$(cat ./acesConfig.conf | grep acesServers | cut -d':' -f 2 | sed -r 's;";;g')
singleNodeArch=$(k3s kubectl get nodes -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)
masterNodeArch=$(k3s kubectl get nodes -l aces-server="true" -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)
workerNodeArch=$(k3s kubectl get nodes -l aces-worker="true" -o wide -L beta.kubernetes.io/arch | head -n 2 | tail -n 1 | rev | cut -d ' ' -f1 | rev)

sed -e 's/{{bucketName}}/'$bucketName'/g;s/{{acesKey}}/'$acesKey'/g;s/{{acesSecret}}/'$acesSecret'/g;s?{{dataPath}}?'$dataPath'?g;s?{{acesServers}}?'$acesServers'?g' "./acesServerDeployment.yaml" | k3s kubectl apply -f -
k3s kubectl wait --for=condition=ready pod aces-0 -n aces --timeout=120s
aces_endpoint="http://$(sudo k3s kubectl describe pod aces-0 --namespace aces | grep Node: | cut -d'/' -f 2):9011"
cat <<EOF | k3s kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: aces-admin-create-bucket
  namespace: aces
  labels:
    app: aces
spec:
  completions: 1
  template:
    spec:
      containers:
      - name: aces-admin
        image: minio/mc
        env:
        - name: MINIO_ACCESS_POINT
          value: $aces_endpoint
        - name: MINIO_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: aces-keys
              key: access-key
        - name: MINIO_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: aces-keys
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
  name: aces-data
spec:
  local:
	type: "COS"
	accessKeyID: "$acesKeyDecoded"
	secretAccessKey: "$acesSecretDecoded"
	endpoint: "$aces_endpoint"
	bucket: "$bucketName"
	readonly: "false"
EOF
echo "Created the pvc named aces-data."
fi

echo "Created the bucket $bucketName"
echo "Created the access point $aces_endpoint"
echo "Access key: $acesKeyDecoded"
echo "Secret key: $acesSecretDecoded"