# ---- Builder stage ----
FROM python:3.12-slim-bookworm AS builder

ARG MAPPROXY_VERSION=6.0.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libgeos-dev \
    libgdal-dev \
    libxml2-dev \
    libxslt-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    MapProxy==${MAPPROXY_VERSION} \
    uwsgi

# ---- Runtime stage ----
FROM python:3.12-slim-bookworm

# Copyright © 2025 Max Dietrich <mail@mxd.codes>. All rights reserved.

LABEL org.opencontainers.image.title="mapproxy-docker" \
      org.opencontainers.image.description="A docker image for http://mapproxy.org/" \
      org.opencontainers.image.url="https://hub.docker.com/repository/docker/mxdcodes/mapproxy-docker" \
      org.opencontainers.image.source="https://github.com/dietrichmax/docker-mapproxy" \
      org.opencontainers.image.authors="Max Dietrich <mail@mxd.codes>" \
      org.opencontainers.image.vendor="Max Dietrich"

ARG MAPPROXY_VERSION=6.0.1
ENV MAPPROXY_VERSION=${MAPPROXY_VERSION}

# Install runtime-only libraries (no -dev packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgeos-c1v5 \
    libgdal32 \
    libxml2 \
    libxslt1.1 \
    libproj25 \
    gettext \
    nginx \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages and binaries from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/uwsgi /usr/local/bin/uwsgi
COPY --from=builder /usr/local/bin/mapproxy-util /usr/local/bin/mapproxy-util

# Create non-root user
RUN groupadd -r mapproxy && useradd -r -g mapproxy -d /mapproxy -s /sbin/nologin mapproxy

# Set up working directory and cache directory
RUN mkdir -p /mapproxy/config /mapproxy/cache_data \
    && chown -R mapproxy:mapproxy /mapproxy

# Fix for potential shared library issues with libproj
RUN ln -sf /usr/lib/$(uname -m)-linux-gnu/libproj.so /usr/lib/$(uname -m)-linux-gnu/liblibproj.so || true

WORKDIR /mapproxy

# Copy application and configuration files
COPY ./build/app.py .
COPY ./build/start.sh .
COPY ./conf/nginx-default.conf /etc/nginx/sites-enabled/default
COPY ./conf/uwsgi.conf uwsgi.default.conf

# Set permissions for non-root operation
RUN chmod +x start.sh \
    && chown -R mapproxy:mapproxy /mapproxy \
    && chown -R mapproxy:mapproxy /var/log/nginx \
    && chown -R mapproxy:mapproxy /var/lib/nginx \
    && chown -R mapproxy:mapproxy /run

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

USER mapproxy

ENTRYPOINT ["/mapproxy/start.sh"]
