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

sed -e 's?{{ACES_SYNC_PATH}}?'$ACES_SYNC_PATH'?g' "./aces_registry_sync_daemon.yaml" | k3s kubectl delete -f -