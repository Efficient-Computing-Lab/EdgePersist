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

FROM python:3.6
MAINTAINER E Psomakelis
 
# Creating Application Source Code Directory
RUN mkdir -p /registry-sync-daemon
# Setting Home Directory for containers
WORKDIR /registry-sync-daemon
# Installing python dependencies
RUN pip install flask kubernetes docker_registry_client kafka-python
# Copying src code to Container
COPY ./python-code /pythoncode
# Application Environment variables
ENV APP_ENV development
# Running Python Application
# CMD python edge_repo_sync_daemon.py