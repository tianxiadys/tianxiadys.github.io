FROM debian:12.9

ARG ARCH=x86_64
ARG REGION=cn-hangzhou
ARG SYSTEM=linux64
ARG VERSION=3.2.4
ARG BINARY=loongcollector_${VERSION}
ARG ZIPNAME=loongcollector-${SYSTEM}
ARG ZIPURL=https://aliyun-observability-release-${REGION}.oss-${REGION}.aliyuncs.com/loongcollector/${SYSTEM}/${VERSION}/${ARCH}/main/${ZIPNAME}.tar.gz

RUN <<EOF
mkdir /app
mkdir /data
apt update
apt install -y curl
apt clean
###
curl -L -o /data/download.tgz ${ZIPURL}
tar -zxf /data/download.tgz -C /app
mv -t /app /app/${ZIPNAME}/bin/${BINARY}
mv -t /app /app/${ZIPNAME}/bin/libcoolbpf.so.1.0.0
mv -t /app /app/${ZIPNAME}/bin/libdcgm.so
mv -t /app /app/${ZIPNAME}/bin/libeBPFDriver.so
mv -t /app /app/${ZIPNAME}/bin/libGoPluginAdapter.so
mv -t /app /app/${ZIPNAME}/bin/libGoPluginBase.so
mv -t /app /app/${ZIPNAME}/resources/ca-bundle.crt
link /app/${BINARY} /app/loongcollector
find /app
find /data
###
rm -rf /data
EOF

WORKDIR "/app"
CMD ["/app/loongcollector", "-enable_host_id=false"]
