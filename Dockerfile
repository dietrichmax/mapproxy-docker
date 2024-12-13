#### Base Image
FROM python:3.12-slim-bookworm AS base-libs

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

ARG MAPPROXY_VERSION=3.1.3

# install dependencies
RUN apt update && apt -y install --no-install-recommends \
  libgeos-dev \
  libgdal-dev \
  libxml2-dev libxslt-dev \
  screen \
  nginx gcc

# install SSH
RUN apt-get install -y --no-install-recommends dialog \
    && apt-get install -y --no-install-recommends openssh-server \
    && echo "root:Docker!" | chpasswd
COPY sshd_config /etc/ssh/

# cleanup
RUN apt-get -y --purge autoremove \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

FROM base-libs AS base

RUN mkdir /mapproxy

RUN groupadd mapproxy && \
    useradd --home-dir /mapproxy -s /bin/bash -g mapproxy mapproxy && \
    chown -R mapproxy:mapproxy /mapproxy

USER mapproxy:mapproxy

WORKDIR /mapproxy

ENV PATH="${PATH}:/mapproxy/.local/bin"

RUN pip install MapProxy==$MAPPROXY_VERSION \
    uwsgi \
    Shapely \
    Pillow \
    lxml \
    pyyaml \
    pyproj && \
    pip cache purge

COPY app.py .
COPY start.sh .
COPY uwsgi.conf .
COPY nginx-default.conf /etc/nginx/sites-enabled/default

EXPOSE 80 2222

USER root:root

RUN chown -R mapproxy:mapproxy /var/log/nginx \
    && chown -R mapproxy:mapproxy /var/lib/nginx \
    && chown -R mapproxy:mapproxy /etc/nginx/conf.d \
    && touch /var/run/nginx.pid \
    && chown -R mapproxy:mapproxy /var/run/nginx.pid

RUN chmod +x ./start.sh

USER mapproxy:mapproxy

CMD ["./start.sh"]