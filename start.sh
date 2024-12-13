#!/bin/bash

done=0
trap 'done=1' TERM INT
cd /mapproxy

# start ssh
service ssh start
echo "Started ssh service"

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