FROM alpine:3.22.2

ARG ARCH=linux-64
ARG VERSION=v26.3.27
ARG ZIPNAME=Xray-${ARCH}
ARG ZIPURL=https://github.com/XTLS/Xray-core/releases/download/${VERSION}/${ZIPNAME}.zip

RUN <<EOF
mkdir /app
mkdir /data
apk add --no-cache curl unzip
###
curl -L -o /data/download.zip ${ZIPURL}
unzip /data/download.zip -d /app
###
rm -rf /data
EOF
