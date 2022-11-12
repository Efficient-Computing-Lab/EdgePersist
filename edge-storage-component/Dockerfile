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