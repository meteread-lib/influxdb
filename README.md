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

Login first (use a personal access token with `write:packages` scope):

```bash
gh auth token | docker login --username $USER --password-stdin ghcr.io
```

### QEMU emulation (one machine)

```bash
# One-time setup
docker buildx create --name multiarch --driver docker-container --use

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag ghcr.io/meteread-lib/influxdb:main \
  --push \
  .
```

### Remote nodes (native, faster for Rust builds)

Builds each architecture natively: amd64 locally, arm64 on a remote machine.
Buildx manages buildkitd containers automatically via Docker context — no manual setup on the remote host needed.

**One-time setup:**

```bash
# Create a Docker context for the remote arm64 host
docker context create raspberrypi --docker "host=ssh://user@arm64-host"

# Local amd64 node
docker buildx create \
  --name multiarch-remote \
  --driver docker-container \
  --platform linux/amd64 \
  --use

# Append remote arm64 node via Docker context
docker buildx create \
  --name multiarch-remote \
  --append \
  --driver docker-container \
  --platform linux/arm64 \
  raspberrypi

docker buildx inspect --bootstrap --builder multiarch-remote
```

**Build and push:**

```bash
docker buildx build \
  --builder multiarch-remote \
  --platform linux/amd64,linux/arm64 \
  --tag ghcr.io/meteread-lib/influxdb:main \
  --push \
  .
```

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
