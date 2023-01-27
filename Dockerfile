ARG RR_VERSION=2.12.2
ARG PHP_VERSION=8.1
ARG COMPOSER_VERSION=latest

FROM composer:$COMPOSER_VERSION AS composer
FROM ghcr.io/roadrunner-server/roadrunner:$RR_VERSION AS roadrunner

FROM php:${PHP_VERSION}-cli-alpine

COPY --from=roadrunner /usr/bin/rr /usr/local/bin/
COPY --from=composer /usr/bin/composer /usr/local/bin/

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

ARG GRPC_VERSION=1.48.0
ARG PROTOBUF_VERSION=3.21.5
ARG WORKER_USER=1337
ARG WORKER_GROUP=1337

RUN apk add --update --no-cache bash less \
&& install-php-extensions \
    pcntl sockets \
    grpc-${GRPC_VERSION} \
    protobuf-${PROTOBUF_VERSION}

RUN addgroup -g $WORKER_GROUP worker
RUN adduser -u $WORKER_USER -G worker -s /bin/bash -D worker

WORKDIR /worker
VOLUME /worker
RUN chown worker:worker /worker
USER worker
