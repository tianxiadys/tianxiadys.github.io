FROM alpine:3.24

RUN apk add --no-cache bash git openssh-client tar
RUN apk add --no-cache maven openjdk25-jdk
RUN apk add --no-cache nodejs pnpm

COPY --chmod=644 profiles/ /root/
