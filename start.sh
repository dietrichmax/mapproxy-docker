#!/bin/bash

source /scripts/env-data.sh

done=0
trap 'done=1' TERM INT
cd /mapproxy

groupadd mapproxy && \
useradd --home-dir /mapproxy -s /bin/bash -g mapproxy mapproxy && \
chown -R mapproxy:mapproxy /mapproxy/

# create config files if they do not exist yet
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi

# entrypoint logic

if [[ "${ALLOW_LISTING}" =~ [Tt][Rr][Uu][Ee] ]]; then
  export ALLOW_LISTING=True
else
  export ALLOW_LISTING=False
fi

service nginx restart &&
su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &"

while [ $done = 0 ]; do
  sleep 1 &
  wait
done