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

k3s kubectl delete -f add_to_hosts.yaml
k3s kubectl delete -f add_certs.yaml
k3s kubectl delete -f deploymentEdited.yaml
k3s kubectl delete secret aces-registry-secret --namespace=aces
k3s kubectl delete secret aces-registry-auth --namespace=aces
sudo rm ./certs/tls.key 
sudo rm ./certs/tls.crt
sudo rm ./auth/htpasswd
sudo rm /usr/local/share/ca-certificates/ca.crt
sudo rm -r /etc/docker/certs.d/accordion.aces.registry:5045
