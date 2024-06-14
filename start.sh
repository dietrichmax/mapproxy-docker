#!/bin/bash

done=0
trap 'done=1' TERM INT
cd /mapproxy

# Add group
echo "Adding mapproxy group"
if [ ! $(getent group mapproxy) ]; then
  groupadd mapproxy
fi

# Add user to system
echo "Adding mapproxy user"
if ! id -u mapproxy >/dev/null 2>&1; then
  useradd --home-dir /mapproxy -s /bin/bash -g mapproxy mapproxy
fi

# fix permissions
echo "Fixing permissions"
chown -R mapproxy:mapproxy /mapproxy/

# create config files if they do not exist yet
echo "Checking if config file exists"
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi

# start mapproxy and nginx
echo "Restarting nginx"
service nginx restart -g 'daemon off;' 

echo "Starting Mapproxy"
su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &"

while [ $done = 0 ]; do
  sleep 1 &
  wait
done