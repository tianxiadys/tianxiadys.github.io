FROM alpine:3.22.2

ARG VERSION=v1.23.5
ARG ARCH=x86_64-unknown-linux-musl
ARG ZIPNAME=shadowsocks-${VERSION}.${ARCH}
ARG ZIPURL=https://github.com/shadowsocks/shadowsocks-rust/releases/download/${VERSION}/${ZIPNAME}.tar.xz

RUN <<EOF
mkdir /app
mkdir /data
apk add --no-cache curl
curl -L -o /data/download.txz ${ZIPURL}
tar -Jxvf /data/download.txz -C /app
rm -rf /data
EOF
