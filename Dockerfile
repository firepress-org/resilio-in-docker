ARG VERSION="2.6.3"
ARG APP_NAME="resilio"
ARG GIT_PROJECT_NAME="rclone-in-docker"

ARG USER="root"
ARG ALPINE_VERSION="3.10"
ARG GIT_REPO_DOCKERFILE="null"
ARG GIT_REPO_SOURCE="https://github.com/bt-sync/sync-docker/blob/master/Dockerfile"

ARG BINARY_NAME="rslsync"
ARG GLIBC_VERSION="2.30-r0"
ARG ALPINE_GLIBC="alpine-glibc"
ARG ALPINE_BASE="alpine-base"

# GNU v3 | Please credit my work if you are re-using some of it :)
# by Pascal Andy | https://pascalandy.com/blog/now/

# https://help.resilio.com/hc/en-us/articles/206216855-Sync-2-x-change-log
# https://github.com/sgerrand/alpine-pkg-glibc"


# ----------------------------------------------
# base LAYER
#   credits: https://github.com/nimmis/docker-alpine-micro
# ----------------------------------------------

FROM alpine:${ALPINE_VERSION} AS alpinebase
RUN set -eux && echo "@community http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    # read packages and update
    apk update && apk upgrade && \
    # add packages
    apk add --no-cache ca-certificates rsyslog logrotate runit && \
    # Make info file about this build
    mkdir -p /etc/BUILDS/ && \
    printf "Build of nimmis/alpine-micro:3.10, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` > /etc/BUILDS/alpine-micro && \
    # install extra from github, including replacement for process 0 (init)
    # add extra package for installation
    apk add curl && \
    cd /tmp && \
    # Install utils and init process
    curl -Ls https://github.com/nimmis/docker-utils/archive/master.tar.gz | tar xfz - && \
    ./docker-utils-master/install.sh && \
    rm -Rf ./docker-utils-master && \
    # Install backup support
    curl -Ls https://github.com/nimmis/backup/archive/master.tar.gz | tar xfz - && \
    ./backup-master/install.sh all && \
    rm -Rf ./backup-master && \
    # remove extra packages
    apk del curl && \
    # fix container bug for syslog
    sed  -i "s|\*.emerg|\#\*.emerg|" /etc/rsyslog.conf && \
    sed -i 's/$ModLoad imklog/#$ModLoad imklog/' /etc/rsyslog.conf && \
    sed -i 's/$KLogPermitNonKernelFacility on/#$KLogPermitNonKernelFacility on/' /etc/rsyslog.conf && \
    # remove cached info
    rm -rf /var/cache/apk/* /tmp /tmp*

COPY script_base/. /
VOLUME /backup
ENV HOME /root
WORKDIR /root
CMD ["/boot.sh"]


# ----------------------------------------------
# alpineglibc LAYER
#   credits: https://github.com/nimmis/docker-alpine-glibc
# ----------------------------------------------
FROM alpinebase AS alpineglibc
ARG GLIBC_VERSION

RUN set -eux && apk --update --no-cache add \
    ca-certificates wget && \
    # install glibc
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q -O glibc-"${GLIBC_VERSION}".apk \
      https://github.com/sgerrand/alpine-pkg-glibc/releases/download/"${GLIBC_VERSION}"/glibc-"${GLIBC_VERSION}".apk && \
    apk add glibc-"${GLIBC_VERSION}".apk && \
    rm glibc-"${GLIBC_VERSION}".apk && \
    # remove un-needed stuff
    apk del ca-certificates wget && \
    rm -rf /var/cache/apk/*


# ----------------------------------------------
# BUILDER LAYER
#   credits: https://github.com/nimmis/docker-resilio-sync
# ----------------------------------------------
FROM alpine:${ALPINE_VERSION} AS builder
ARG VERSION
ARG APP_NAME
ARG BINARY_NAME

RUN set -eux && apk --update --no-cache add \
    ca-certificates curl upx

# Download app
WORKDIR /tmp
RUN set -eux && curl https://download-cdn.resilio.com/"${VERSION}"/linux-x64/resilio-sync_x64.tar.gz | tar xfz - && \
    mv "${BINARY_NAME}" /usr/local/bin && \
    apk del ca-certificates curl && \
    rm -rf /var/cache/apk/* /tmp

# Compress binary
RUN set -eux && upx /usr/local/bin/"${BINARY_NAME}" && \
    upx -t /usr/local/bin/"${BINARY_NAME}"


# ----------------------------------------------
# FINAL LAYER
# ----------------------------------------------
FROM alpineglibc AS final
ARG VERSION
ARG APP_NAME
ARG USER
ARG ALPINE_VERSION
ARG BINARY_NAME

ENV APP_NAME="${APP_NAME}"
ENV VERSION="${VERSION}"
ENV GIT_REPO_DOCKERFILE="${GIT_REPO_DOCKERFILE}"
ENV ALPINE_VERSION="${ALPINE_VERSION}"

ENV CREATED_DATE="$(date "+%Y-%m-%d_%HH%Ms%S")"
ENV SOURCE_COMMIT="$(git rev-parse --short HEAD)"

# resilio configurations
ENV RSLSYNC_SIZE="1024" \
    RSLSYNC_TRASH="false" \
    RSLSYNC_TRASH_TIME="0"

# credits: https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="${APP_NAME}"                                              \
      org.opencontainers.image.version="${VERSION}"                                             \
      org.opencontainers.image.description="See README.md"                                      \
      org.opencontainers.image.authors="Pascal Andy https://firepress.org/en/contact/"          \
      org.opencontainers.image.created="${CREATED_DATE}"                                        \
      org.opencontainers.image.revision="${SOURCE_COMMIT}"                                      \
      org.opencontainers.image.source="${GIT_REPO_DOCKERFILE}"                                  \
      org.opencontainers.image.licenses="GNUv3. See README.md"                                  \
      org.firepress.image.user="${USER}"                                                        \
      org.firepress.image.alpineversion="{ALPINE_VERSION}"                                      \
      org.firepress.image.field1="not_set"                                                      \
      org.firepress.image.field2="not_set"                                                      \
      org.firepress.image.schemaversion="1.0"

COPY script_glibc/. /
COPY --from=builder /usr/local/bin/"${BINARY_NAME}" /usr/local/bin/"${BINARY_NAME}"
VOLUME /data
EXPOSE 33333
