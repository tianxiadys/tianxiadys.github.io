FROM alpine:3.24

RUN <<EOF
apk add --no-cache bash git openssh-client
apk add --no-cache maven openjdk25-jdk
apk add --no-cache nodejs pnpm
EOF

COPY --chmod=644 profiles/ /root/
