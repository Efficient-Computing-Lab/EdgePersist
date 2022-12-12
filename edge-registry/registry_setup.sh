#	This file is part of Edge Registry.
#
#    Edge Registry is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Edge Registry is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Edge Registry.  If not, see https://www.gnu.org/licenses/.

sudo apt-get install -y apache2-utils
mkdir ./certs
mkdir ./auth
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ./certs/tls.key -x509 -days 365  -subj "/C=GR/ST=./L=./O=./CN=dkms.edge.registry" -addext "subjectAltName = DNS:dkms.edge.registry" -out ./certs/tls.crt
htpasswd -cB -db auth/htpasswd edgUser edgPass5
k3s kubectl create secret tls edge-registry-secret --cert=./certs/tls.crt --key=./certs/tls.key --namespace=edgestorage
k3s kubectl create secret generic edge-registry-auth --from-file=./auth/htpasswd --namespace=edgestorage
edgestorage_api="http://$(sudo k3s kubectl describe pod edgestorage-0 --namespace edgestorage | grep Node: | cut -d'/' -f 2):9010"
edge_registry_endpoint="$(sudo k3s kubectl describe pod edgestorage-0 --namespace edgestorage | grep Node: | cut -d'/' -f 2)"
sed -e 's?{{EDGE_ENDPOINT}}?"'$edgestorage_api'"?g' "./deployment.yaml" > ./deploymentEdited.yaml
sed -e 's?{{EDGE_REGISTRY_ENDPOINT}}?"'$edge_registry_endpoint'"?g' "./add_to_hosts.yaml" > ./add_to_hostsEdited.yaml
k3s kubectl apply -f deploymentEdited.yaml
k3s kubectl apply -f add_certs.yaml
k3s kubectl apply -f add_to_hostsEdited.yaml
k3s kubectl wait --for=condition=ready pods --all -n edgestorage --timeout=20s
sudo update-ca-certificates
sudo systemctl restart containerd
sudo systemctl restart k3s
echo "Registry listening on $edge_registry_endpoint:5045"
echo "You can push an image with the following commands, using hello-world as an example:"
echo "sudo docker run hello-world"
echo "sudo docker tag hello-world dkms.edge.registry:5045/hello-world"
echo "sudo docker push dkms.edge.registry:5045/hello-world"
echo "Then you can test it by running k3s kubectl apply -f test_deploy.yaml"
# echo "Username: edgUser"
# echo "Password: edgPass5"

