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

FROM alpine as builder

WORKDIR /root/
RUN ARCH=`uname -m` && \
	if [ "$ARCH" == "x86_64" ]; then \
		apk add --update curl && \
		curl -sSLO https://dl.minio.io/server/minio/release/linux-amd64/minio && \
		chmod 0755 ./minio; \
	else \
		apk add --update curl && \
		curl -sSLO https://dl.minio.io/server/minio/release/linux-arm/minio && \
		chmod 0755 ./minio; \
	fi

FROM scratch
COPY --from=builder /root/minio /usr/bin/minio

EXPOSE 9000
ENTRYPOINT ["minio"]
VOLUME ["/export"]