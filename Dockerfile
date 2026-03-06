#syntax=docker/dockerfile:1.2
ARG RUST_VERSION=1.92
FROM rust:${RUST_VERSION}-slim-bookworm AS build

USER root

RUN apt update \
    && apt install --yes binutils build-essential pkg-config libssl-dev clang lld git protobuf-compiler libz-dev \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

RUN mkdir /influxdb3
WORKDIR /influxdb3

ARG INFLUXDB_VERSION=main

RUN git clone --depth 1 --branch ${INFLUXDB_VERSION} https://github.com/influxdata/influxdb.git .

# Build WITHOUT jemalloc_replacing_malloc to avoid page size issues on ARM64
RUN \
    cargo build \
      --package=influxdb3 \
      --profile=release \
      --no-default-features \
      --features="aws,gcp,azure" && \
    objcopy --compress-debug-sections target/release/influxdb3 && \
    cp target/release/influxdb3 /root/influxdb3

FROM debian:bookworm-slim

RUN apt update \
    && apt install --yes ca-certificates libssl3 --no-install-recommends \
    && rm -rf /var/lib/{apt,dpkg,cache,log} \
    && groupadd --gid 1500 influxdb3 \
    && useradd --uid 1500 --gid influxdb3 --shell /bin/bash --create-home influxdb3

RUN mkdir -p /var/lib/influxdb3 && chown influxdb3:influxdb3 /var/lib/influxdb3
RUN mkdir /plugins && chown influxdb3:influxdb3 /plugins

USER influxdb3
RUN mkdir -p ~/.influxdb3

ENV INFLUXDB3_PLUGIN_DIR=/plugins
ENV LOG_FILTER=info

COPY --from=build /root/influxdb3 /usr/bin/influxdb3

EXPOSE 8181

ENTRYPOINT ["influxdb3"]
CMD ["serve"]
