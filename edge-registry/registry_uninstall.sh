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

k3s kubectl delete -f add_to_hosts.yaml
k3s kubectl delete -f add_certs.yaml
k3s kubectl delete -f deploymentEdited.yaml
k3s kubectl delete secret edge-registry-secret --namespace=edgestorage
k3s kubectl delete secret edge-registry-auth --namespace=edgestorage
sudo rm ./certs/tls.key 
sudo rm ./certs/tls.crt
sudo rm ./auth/htpasswd
sudo rm /usr/local/share/ca-certificates/ca.crt
sudo rm -r /etc/docker/certs.d/dkms.edge.registry:5045
