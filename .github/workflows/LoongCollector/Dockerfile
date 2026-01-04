FROM debian:12.12

ARG ARCH=x86_64
ARG REGION=cn-hangzhou
ARG SYSTEM=linux64
ARG VERSION=3.2.4
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
mv -t /app /app/${ZIPNAME}/bin/*
mv -t /app /app/${ZIPNAME}/conf
mv -t /app /app/${ZIPNAME}/resources/*
link /app/loongcollector_${VERSION} /app/loongcollector
find /app
find /data
###
rm -rf /data
EOF

WORKDIR "/app"
CMD ["/app/loongcollector", "-enable_host_id=false"]
