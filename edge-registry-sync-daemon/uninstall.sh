#	This file is part of Edge Registry Syncer.
#
#    Edge Registry Syncer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Edge Registry Syncer is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Edge Registry Syncer.  If not, see https://www.gnu.org/licenses/.

sed -e 's?{{EDGE_SYNC_PATH}}?'$EDGE_SYNC_PATH'?g' "./edge_registry_sync_daemon.yaml" | k3s kubectl delete -f -