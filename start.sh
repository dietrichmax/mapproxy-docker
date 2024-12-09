#!/bin/bash

done=0
trap 'done=1' TERM INT
cd /mapproxy

service ssh start
echo "Started ssh service"

# create config files if they do not exist yet
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi


# start nginx
service nginx restart -g 'daemon off;' 
echo "Started Nginx"

# start mapproxy
/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &
echo "Started Mapproxy"

while [ $done = 0 ]; do
  sleep 1 &
  wait
done
