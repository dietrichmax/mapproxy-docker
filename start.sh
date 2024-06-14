#!/bin/bash

USER_NAME=${USER:-mapproxy}
USER_ID=${MAPPROXY_USER_ID:-1003}
GROUP_NAME=${GROUP_NAME:-mapproxy}
GROUP_ID=${MAPPROXY_GROUP_ID:-1003}

cd /mapproxy

# Add group
if [ ! $(getent group mapproxy) ]; then
  groupadd mapproxy
fi

# Add user to system
if ! id -u mapproxy >/dev/null 2>&1; then
  useradd --home-dir /mapproxy -s /bin/bash -g mapproxy mapproxy
fi

# create config files if they do not exist yet
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi

# fix permissions
chown -R mapproxy:mapproxy /mapproxy/

# start mapproxy and nginx
service nginx restart -g 'daemon off;' 
su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &"
echo "Started Mapproxy"