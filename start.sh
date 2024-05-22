#!/bin/bash

source /env-data.sh

done=0
trap 'done=1' TERM INT
cd /mapproxy

groupadd mapproxy && \
useradd --home-dir /mapproxy -s /bin/bash -g mapproxy mapproxy && \

# Create directories
mkdir -p "${MAPPROXY_DATA_DIR}" "${MAPPROXY_CACHE_DIR}"
chown -R mapproxy:mapproxy "${MAPPROXY_DATA_DIR}"
chown -R mapproxy:mapproxy "${MAPPROXY_CACHE_DIR}"

# create config files if they do not exist yet
if [ ! -f "${MAPPROXY_DATA_DIR}/mapproxy.yaml" ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi

service nginx restart &&
su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &"

while [ $done = 0 ]; do
  sleep 1 &
  wait
done
