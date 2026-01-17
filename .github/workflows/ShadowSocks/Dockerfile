FROM alpine:3.23.2

ARG ARCH=x86_64-unknown-linux-musl
ARG VERSION=v1.24.0
ARG ZIPNAME=shadowsocks-${VERSION}.${ARCH}
ARG ZIPURL=https://github.com/shadowsocks/shadowsocks-rust/releases/download/${VERSION}/${ZIPNAME}.tar.xz

RUN <<EOF
mkdir /data
apk add --no-cache curl
###
curl -L -o /data/download.txz ${ZIPURL}
tar -Jxf /data/download.txz -C /bin
###
rm -rf /data
EOF
