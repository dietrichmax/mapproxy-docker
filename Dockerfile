#### Base Image
FROM python:3.10-slim-bookworm

# Copyright © 2024 Max Dietrich <mail@mxd.codes>. All rights reserved.

# Add Open Container Initiative (OCI) annotations.
# See: https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.title="mapproxy-docker"
LABEL org.opencontainers.image.description="A docker image for http://mapproxy.org/"
LABEL org.opencontainers.image.url="https://hub.docker.com/repository/docker/mxdcodes/mapproxy-docker"
LABEL org.opencontainers.image.source="https://github.com/dietrichmax/docker-mapproxy"
LABEL org.opencontainers.image.documentation=""
LABEL org.opencontainers.image.authors="Max Dietrich <mail@mxd.codes>"
LABEL org.opencontainers.image.vendor="Max Dietrich"

ARG MAPPROXY_VERSION=2.0.2

# install dependencies
RUN apt update && apt -y install --no-install-recommends \
  python3-pil \
  python3-yaml \
  python3-pyproj \
  libgeos-dev \
  python3-lxml \
  libgdal-dev \
  python3-shapely \
  libxml2-dev libxslt-dev \
  nginx gcc

# cleanup
RUN apt-get -y --purge autoremove \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir /mapproxy
RUN mkdir /mapproxy/cache_data

WORKDIR /mapproxy

# fix potential issue finding correct shared library libproj (fixed in newer releases)
RUN ln -s /usr/lib/`uname -m`-linux-gnu/libproj.so /usr/lib/`uname -m`-linux-gnu/liblibproj.so

RUN pip install MapProxy==$MAPPROXY_VERSION \
    uwsgi \
    pyproj && \
    pip cache purge

COPY app.py .
COPY start.sh .
COPY uwsgi.conf .
COPY nginx-default.conf /etc/nginx/sites-enabled/default

RUN chmod +x ./start.sh

EXPOSE 80

ENTRYPOINT ["bash", "-c", "./start.sh"]
