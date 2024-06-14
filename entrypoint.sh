#!/bin/bash

cd /mapproxy

groupadd mapproxy && \
useradd --home-dir /mapproxy -s /bin/bash -g mapproxy mapproxy && \
chown -R mapproxy:mapproxy /mapproxy/

# create config files if they do not exist yet
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi


if [[ "${ALLOW_LISTING}" =~ [Tt][Rr][Uu][Ee] ]]; then
  export ALLOW_LISTING=True
else
  export ALLOW_LISTING=False
fi

su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf && /usr/sbin/nginx daemon off"