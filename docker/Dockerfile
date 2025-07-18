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
ARG MAPPROXY_VERSION=5.0.0
ENV MAPPROXY_VERSION=${MAPPROXY_VERSION}

# Install dependencies in a single RUN command to reduce image layers
RUN apt update && apt -y install --no-install-recommends \
    libgeos-dev \
    libgdal-dev \
    libxml2-dev libxslt-dev \
    screen \
    gettext \
    nginx \
    gcc \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set up MapProxy working directory
RUN mkdir /mapproxy
WORKDIR /mapproxy

# Fix for potential shared library issues with libproj (may not be necessary in newer releases)
RUN ln -s /usr/lib/$(uname -m)-linux-gnu/libproj.so /usr/lib/$(uname -m)-linux-gnu/liblibproj.so

# Install Python dependencies in a single RUN command to reduce image layers
RUN pip install MapProxy==$MAPPROXY_VERSION \
    uwsgi \
    Shapely \
    Pillow \
    lxml \
    pyyaml \
    pyproj \
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

HEALTHCHECK CMD curl --fail http://localhost || exit 1

# Use ENTRYPOINT to execute the start.sh script
ENTRYPOINT ["bash", "-c", "./start.sh"]
