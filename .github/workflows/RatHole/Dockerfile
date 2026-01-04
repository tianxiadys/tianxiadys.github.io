FROM debian:12.12

ARG ARCH=x86_64-unknown-linux-gnu
ARG VERSION=v0.5.0
ARG ZIPNAME=rathole-${ARCH}
ARG ZIPURL=https://github.com/rapiz1/rathole/releases/download/${VERSION}/${ZIPNAME}.zip

RUN <<EOF
mkdir /app
mkdir /data
apt update
apt install -y curl unzip
apt clean
###
curl -L -o /data/download.zip ${ZIPURL}
unzip /data/download.zip rathole -d /app
###
rm -rf /data
EOF

CMD ["/app/rathole", "/data/rathole.toml"]
