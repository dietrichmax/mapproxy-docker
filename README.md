<div align="center">

# MapProxy Docker Image

**Docker image for [MapProxy](https://mapproxy.org/)**

[![Version](https://img.shields.io/github/v/release/dietrichmax/mapproxy-docker)](https://github.com/dietrichmax/mapproxy-docker/releases)  [![Docker Pulls](https://img.shields.io/docker/pulls/mxdcodes/mapproxy-docker)](https://hub.docker.com/r/mxdcodes/mapproxy-docker)  [![Build Status](https://github.com/dietrichmax/mapproxy-docker/actions/workflows/docker_build.yml/badge.svg)](https://github.com/dietrichmax/mapproxy-docker/actions/workflows/docker_build.yml)  ![License: Apache-2.0](https://img.shields.io/github/license/dietrichmax/mapproxy-docker)

</div>

## Overview

Docker image for [MapProxy](https://mapproxy.org/) with Nginx and uWSGI. Uses a multi-stage build to keep the final image small, runs as a non-root user, and includes gzip compression and production-tuned uWSGI settings out of the box.

---

## Usage

### Build

```bash
docker build -t mapproxy-docker -f docker/Dockerfile .
```

### Run

```bash
docker run -p 8080:8080 --name mapproxy mapproxy-docker
```

MapProxy will be available at `http://localhost:8080`.

### With volume mounts

```bash
docker run -p 8080:8080 \
  -v ./config:/mapproxy/config \
  -v ./cache_data:/mapproxy/cache_data \
  --name mapproxy mapproxy-docker
```

### Access the container

```bash
docker exec -ti mapproxy /bin/bash
```

### Configuration

MapProxy configuration files go in `/mapproxy/config`. If no `.yaml` file is found on startup, a default configuration is created automatically via `mapproxy-util`.

---

## Environment Variables

| Variable                    | Description                                             | Default              |
|-----------------------------|---------------------------------------------------------|----------------------|
| `UWSGI_PROCESSES`          | Number of uWSGI worker processes                        | Number of CPU cores  |
| `UWSGI_THREADS`            | Number of threads per worker                            | CPU cores x 2       |
| `MAPPROXY_CONFIG_DATA_PATH` | Path to MapProxy configuration directory               | `/mapproxy/config`   |
| `MAPPROXY_CACHE_DATA_PATH`  | Path to MapProxy cache directory                       | `/mapproxy/cache_data` |
| `MAPPROXY_ALLOW_LISTING`    | Enable public listing of the config directory (`true`/`false`) | `false`        |

---

## Architecture

- **Nginx** listens on port 8080 and proxies requests to uWSGI via a unix socket
- **uWSGI** runs MapProxy with configurable worker processes and threads
- The image uses a multi-stage build: compilation happens in a builder stage, the final image contains only runtime libraries
- Runs as non-root `mapproxy` user
- Includes a Docker `HEALTHCHECK`

### Files in the image

- `/mapproxy/app.py` — WSGI application entry point
- `/mapproxy/start.sh` — startup script (starts Nginx, then hands off to uWSGI)
- `/etc/nginx/sites-enabled/default` — Nginx configuration

---

## License

[Apache-2.0](LICENSE)
