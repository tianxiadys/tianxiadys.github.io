FROM alpine:3.22.2

ARG VERSION=v1.23.5
ARG ARCH=x86_64-unknown-linux-musl
ARG ZIPNAME=shadowsocks-${VERSION}.${ARCH}
ARG ZIPURL=https://github.com/shadowsocks/shadowsocks-rust/releases/download/${VERSION}/${ZIPNAME}.tar.xz

RUN <<EOF
apk add --no-cache curl
curl -L -o /root/download.txz ${ZIPURL}
tar -Jxvf /root/download.txz -C /bin
rm -rf /root
EOF
