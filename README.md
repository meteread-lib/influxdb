# influxdb

Multi-architecture Docker image for [InfluxDB 3](https://github.com/influxdata/influxdb), built for `linux/amd64` and `linux/arm64`.

The image is built from source with jemalloc's `replacing_malloc` disabled to avoid page size issues on ARM64.

## Usage

```bash
docker pull ghcr.io/meteread-lib/influxdb:main
docker run -p 8181:8181 -v influxdb-data:/var/lib/influxdb3 ghcr.io/meteread-lib/influxdb:main
```

## Build

```bash
docker build -t influxdb .
```

To build a specific InfluxDB version:

```bash
docker build --build-arg INFLUXDB_VERSION=v3.0.0 -t influxdb .
```

## Build and push to GitHub Container Registry

```bash
# Login to ghcr.io (use a personal access token with write:packages scope)
gh auth token | docker login --username $USER --password-stdin ghcr.io

# Create a multi-platform builder (one-time setup)
docker buildx create --name multiarch --driver docker-container --use

# Build and push
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag ghcr.io/meteread-lib/influxdb:main \
  --push \
  .
```

The CI workflow builds and pushes automatically on every push to `main`.

## Build args

| Arg                | Default | Description                          |
|--------------------|---------|--------------------------------------|
| `RUST_VERSION`     | `1.92`  | Rust toolchain version               |
| `INFLUXDB_VERSION` | `main`  | InfluxDB git branch or tag to build  |

## Ports

| Port | Description        |
|------|--------------------|
| 8181 | InfluxDB HTTP API  |

## License

[MIT](LICENSE)