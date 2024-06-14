#### Base Image
FROM python:3.12-slim-bookworm

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
ARG UNAME=mapproxy
ARG UID=1003
ARG GID=1003

# install dependencies
RUN apt update && apt -y install --no-install-recommends \
  libgeos-dev \
  libgdal-dev \
  libxml2-dev libxslt-dev \
#  python3-virtualenv \
  nginx gcc

# cleanup
RUN apt-get -y --purge autoremove \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir /mapproxy
WORKDIR /mapproxy

# fix potential issue finding correct shared library libproj (fixed in newer releases)
RUN ln -s /usr/lib/`uname -m`-linux-gnu/libproj.so /usr/lib/`uname -m`-linux-gnu/liblibproj.so

# create a new virtual environment
#RUN virtualenv --system-site-packages mapproxy
#RUN source mapproxy/bin/activate

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

RUN groupadd -g $GID $UNAME
RUN useradd -m -u $UID -g $GID -s /bin/bash $UNAME
USER $UNAME

EXPOSE 80

CMD ["/usr/local/bin/uwsgi", "--ini", "/mapproxy/uwsgi.conf", "&&", "/usr/sbin/nginx", "-g", "daemon off;"]