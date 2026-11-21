# runner 用的 job 镜像：java + mvn + git + node + pnpm + ssh/scp/rsync
#
# Alpine 3.24 官方仓库里：
#   openjdk25-jdk 25.0.5.1、maven 3.9.16、nodejs 24.22.3、pnpm 11.28.13
# 其中 nodejs 只有 24，拿不到 26，所以 node 从官方 alpine 镜像里取二进制。

# 只取 node/npm，不引入整个镜像
FROM node:26.13.1-alpine3.24 AS node

FROM alpine:3.24

ARG MAVEN_VERSION=3.10.1
ARG PNPM_VERSION=11
# 给 heredoc 里的 shell 用
ENV MAVEN_VERSION=${MAVEN_VERSION} \
    PNPM_VERSION=${PNPM_VERSION}

ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-25-openjdk \
    PATH=/usr/lib/jvm/java-25-openjdk/bin:/opt/maven/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin

RUN <<EOF
set -eux
apk update
apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    libatomic \
    libstdc++ \
    openssh-client \
    openjdk25-jdk \
    rsync \
    tzdata \
    xz
rm -rf /var/cache/apk/*
EOF

# node 26.13.1 + npm + npx（musl，和 alpine 3.24 匹配）
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

# pnpm 用 node 自带的 npm 装，版本可控（不依赖发行版何时打包）
RUN <<EOF
set -eux
npm install -g "pnpm@${PNPM_VERSION}"
rm -rf /root/.npm
EOF

# maven 用官方 tarball，绕开发行版版本；apk 里的 maven 是 3.9.16
RUN <<EOF
set -eux
curl -fsSLo /tmp/maven.tar.gz \
    "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
mkdir -p /opt
tar -xzf /tmp/maven.tar.gz -C /opt
ln -s "/opt/apache-maven-${MAVEN_VERSION}" /opt/maven
rm /tmp/maven.tar.gz
EOF

# 缺任何一项都让构建失败
RUN set -eux; \
    java -version; \
    mvn -v; \
    git --version; \
    node --version; \
    npm --version; \
    pnpm --version; \
    ssh -V; \
    scp -V 2>&1 | head -1 || true; \
    rsync --version | head -1
