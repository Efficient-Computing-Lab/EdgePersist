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

sudo apt-get install -y apache2-utils
mkdir ./certs
mkdir ./auth
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ./certs/tls.key -x509 -days 365  -subj "/C=GR/ST=./L=./O=./CN=accordion.aces.registry" -addext "subjectAltName = DNS:accordion.aces.registry" -out ./certs/tls.crt
htpasswd -cB -db auth/htpasswd accUser accPass5
k3s kubectl create secret tls aces-registry-secret --cert=./certs/tls.crt --key=./certs/tls.key --namespace=aces
k3s kubectl create secret generic aces-registry-auth --from-file=./auth/htpasswd --namespace=aces
aces_endpoint="http://$(sudo k3s kubectl describe pod aces-0 --namespace aces | grep Node: | cut -d'/' -f 2):9011"
aces_registry_endpoint="$(sudo k3s kubectl describe pod aces-0 --namespace aces | grep Node: | cut -d'/' -f 2)"
#aces_endpoint="http://10.95.132.204:9011/"
#aces_registry_endpoint="$(sudo k3s kubectl get nodes -o wide | grep Ready | cut -d' ' -f 17)"
sed -e 's?{{ACES_ENDPOINT}}?"'$aces_endpoint'"?g' "./deployment.yaml" > ./deploymentEdited.yaml
sed -e 's?{{ACES_REGISTRY_ENDPOINT}}?"'$aces_registry_endpoint'"?g' "./add_to_hosts.yaml" > ./add_to_hostsEdited.yaml
k3s kubectl apply -f deploymentEdited.yaml
k3s kubectl apply -f add_certs.yaml
k3s kubectl apply -f add_to_hostsEdited.yaml
k3s kubectl wait --for=condition=ready pods --all -n aces --timeout=40s
sudo update-ca-certificates
sudo systemctl restart containerd
sudo systemctl restart k3s
echo "Registry listening on $aces_registry_endpoint:5045"
echo "You can push an image with the following commands, using hello-world as an example:"
echo "sudo docker run hello-world"
echo "sudo docker tag hello-world accordion.aces.registry:5045/hello-world"
echo "sudo docker push accordion.aces.registry:5045/hello-world"
echo "Then you can test it by running k3s kubectl apply -f test_deploy.yaml"
# echo "Username: accUser"
# echo "Password: accPass5"

