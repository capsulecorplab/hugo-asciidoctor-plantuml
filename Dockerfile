FROM capsulecorplab/asciidoctor-extended:latest

# Install golang from source
ARG GOLANG_VERSION=1.14.3
RUN apk update && \
    apk add --no-cache --virtual .build-deps bash gcc musl-dev openssl go

RUN wget https://dl.google.com/go/go$GOLANG_VERSION.src.tar.gz -O go$GOLANG_VERSION.src.tar.gz && \
    tar -C /usr/local -xzf go$GOLANG_VERSION.src.tar.gz

RUN cd /usr/local/go/src && \
    ./make.bash

ENV PATH=$PATH:/usr/local/go/bin

RUN rm go$GOLANG_VERSION.src.tar.gz
RUN apk del .build-deps
RUN go version

# Install Node.js and npm
RUN apk add --update nodejs nodejs-npm

# Install hugo
ARG DOCKER_HUGO_VERSION="0.76.5"
ENV DOCKER_HUGO_NAME="hugo_extended_${DOCKER_HUGO_VERSION}_Linux-64bit"
ENV DOCKER_HUGO_BASE_URL="https://github.com/gohugoio/hugo/releases/download"
ENV DOCKER_HUGO_URL="${DOCKER_HUGO_BASE_URL}/v${DOCKER_HUGO_VERSION}/${DOCKER_HUGO_NAME}.tar.gz"
ENV DOCKER_HUGO_CHECKSUM_URL="${DOCKER_HUGO_BASE_URL}/v${DOCKER_HUGO_VERSION}/hugo_${DOCKER_HUGO_VERSION}_checksums.txt"
ARG INSTALL_NODE="false"

RUN apk add --no-cache --virtual .build-deps
RUN apk add --no-cache --update \
    git \
    bash \
    make \
    musl \
    ca-certificates \
    libstdc++
RUN wget "${DOCKER_HUGO_URL}"
RUN wget "${DOCKER_HUGO_CHECKSUM_URL}"
RUN grep "${DOCKER_HUGO_NAME}.tar.gz" "./hugo_${DOCKER_HUGO_VERSION}_checksums.txt" | sha256sum -c - && \
    tar -zxvf "${DOCKER_HUGO_NAME}.tar.gz" && \
    mv ./hugo /usr/bin/hugo && \
    hugo version
RUN apk del .build-deps
RUN apk del make

WORKDIR /src
