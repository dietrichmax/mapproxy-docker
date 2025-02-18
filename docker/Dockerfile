# Use a minimal base image
FROM python:3.12-slim-bookworm

# Copyright © 2024 Max Dietrich <mail@mxd.codes>. All rights reserved.

# Add Open Container Initiative (OCI) annotations.
LABEL org.opencontainers.image.title="mapproxy-docker" \
      org.opencontainers.image.description="A docker image for http://mapproxy.org/" \
      org.opencontainers.image.url="https://hub.docker.com/repository/docker/mxdcodes/mapproxy-docker" \
      org.opencontainers.image.source="https://github.com/dietrichmax/docker-mapproxy" \
      org.opencontainers.image.authors="Max Dietrich <mail@mxd.codes>" \
      org.opencontainers.image.vendor="Max Dietrich"

# Set build-time argument for MapProxy version
ARG MAPPROXY_VERSION=3.1.3

# Use secret mounts for build-time secrets
RUN --mount=type=secret,id=ROOT_PASSWORD \
    export ROOT_PASSWORD=$(cat /run/secrets/ROOT_PASSWORD) && \

# Install dependencies in a single RUN command to reduce image layers
RUN apt update && apt -y install --no-install-recommends \
    libgeos-dev \
    libgdal-dev \
    libxml2-dev libxslt-dev \
    screen \
    gettext \
    nginx \
    gcc \
    openssh-server \
    && echo "root:${ROOT_PASSWORD}" | chpasswd \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# SSH configuration (if needed, otherwise this can be omitted)
COPY ./conf/sshd_config /etc/ssh/

# Set up MapProxy working directory
RUN mkdir /mapproxy
WORKDIR /mapproxy

# Fix for potential shared library issues with libproj (may not be necessary in newer releases)
RUN ln -s /usr/lib/$(uname -m)-linux-gnu/libproj.so /usr/lib/$(uname -m)-linux-gnu/liblibproj.so

# Install Python dependencies in a single RUN command to reduce image layers
RUN pip install MapProxy==$MAPPROXY_VERSION \
    requests \
    uwsgi \
    Shapely \
    Pillow \
    lxml \
    pyyaml \
    pyproj \
    redis \
    azure-storage-blob \
    && pip cache purge

# Copy application and configuration files
COPY ./build/app.py .
COPY ./build/start.sh .
COPY ./conf/nginx-default.conf /etc/nginx/sites-enabled/default
COPY ./conf/uwsgi.conf uwsgi.default.conf

# Make start.sh executable
RUN chmod +x start.sh

# Expose ports
EXPOSE 80 2222

# Copy the health check script
COPY ./build/health_check.py /mapproxy/health_check.py

# Health check to ensure MapProxy is running and accessible
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD python /mapproxy/health_check.py || exit 1

# Use ENTRYPOINT to execute the start.sh script
ENTRYPOINT ["bash", "-c", "./start.sh"]
