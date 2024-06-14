#!/bin/bash

cd /mapproxy

###
# Mapproxy user
###

USER_NAME=${USER:-mapproxy}
USER_ID=${MAPPROXY_USER_ID:-1003}
GROUP_NAME=${GROUP_NAME:-mapproxy}
GROUP_ID=${MAPPROXY_GROUP_ID:-1003}

# Add group
if [ ! $(getent group "${GROUP_NAME}") ]; then
  groupadd -r "${GROUP_NAME}" -g "${GROUP_ID}"
fi

# Add user to system
if ! id -u "${USER_NAME}" >/dev/null 2>&1; then
  useradd -l -m -d /home/"${USER_NAME}"/ -u "${USER_ID}" --gid "${GROUP_ID}" -s /bin/bash -G "${GROUP_NAME}" "${USER_NAME}"
fi

# create config files if they do not exist yet
if [ ! -f /mapproxy/config/mapproxy.yaml ]; then
  echo "No mapproxy configuration found. Creating one from template."
  mapproxy-util create -t base-config config
fi

# fix permissions
chown -R mapproxy:mapproxy /mapproxy/

# start mapproxy and nginx
service nginx restart -g 'daemon off;' &&
su mapproxy -c "/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf