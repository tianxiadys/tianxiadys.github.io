FROM debian:12.9

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
curl -L -o /data/download.tgz ${ZIPURL}
tar -zxvf /data/download.tgz --strip-components 1 -C /app ${ZIPNAME}
find /app
find /data
rm -rf /data
EOF
