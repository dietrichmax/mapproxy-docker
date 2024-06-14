#!/bin/bash

cd /mapproxy

# Add group
if [ ! $(getent group mapproxy) ]; then
  groupadd -r "mapproxy -g 1003"
fi

# Add user to system
if ! id -u 1003 >/dev/null 2>&1; then
  useradd -l -m -d /home/mapproxy/ -u 1003 --gid 1003 -s /bin/bash -G mapproxy mapproxy
fi

# create config files if they do not exist yet
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi

# fix permissions
chown -R mapproxy:mapproxy /mapproxy/
echo "fixed permission"

# start mapproxy and nginx
service nginx restart -g 'daemon off;' 
su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &"
echo "Started Mapproxy"