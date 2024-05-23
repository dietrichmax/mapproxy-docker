#!/bin/bash

done=0
trap 'done=1' TERM INT
cd /mapproxy

groupadd -r mapproxy -g 1003 && \
useradd -l -m -d /mapproxy -u 1003 --gid 1003 -s /bin/bash -G mapproxy mapproxy && \
chown -R mapproxy:mapproxy /mapproxy/

# create config files if they do not exist yet
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi

service nginx restart &&
su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &"

while [ $done = 0 ]; do
  sleep 1 &
  wait
done