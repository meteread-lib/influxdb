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