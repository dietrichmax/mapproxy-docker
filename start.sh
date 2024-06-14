#!/bin/bash

done=0
trap 'done=1' TERM INT
cd /mapproxy

# Add group
if [ ! $(getent group mapproxy) ]; then
  groupadd mapproxy
fi

# Add user to system
if ! id -u mapproxy >/dev/null 2>&1; then
  useradd --home-dir /mapproxy -s /bin/bash -g mapproxy mapproxy
fi

# fix permissions
chown -R mapproxy:mapproxy /mapproxy/

# create config files if they do not exist yet
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi

# start mapproxy and nginx
service nginx restart -g 'daemon off;' 

su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &"
echo "Started Mapproxy"

while [ $done = 0 ]; do
  sleep 1 &
  wait
done