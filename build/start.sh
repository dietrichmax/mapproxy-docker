
#!/bin/bash

export UWSGI_PROCESSES=${UWSGI_PROCESSES:-$(nproc)}
export UWSGI_THREADS=${UWSGI_THREADS:-$(( $(nproc) * 2 ))}
export MAPPROXY_CONFIG_DATA_PATH="${MAPPROXY_CONFIG_DATA_PATH:-/mapproxy/config}"
export MAPPROXY_CACHE_DATA_PATH="${MAPPROXY_CACHE_DATA_PATH:-/mapproxy/cache_data}"
export MAPPROXY_ALLOW_LISTING=${MAPPROXY_ALLOW_LISTING:-false}

done=0
trap 'done=1' TERM INT
cd /mapproxy

# Display environment variables
echo "MAPPROXY_CONFIG_DATA_PATH=$MAPPROXY_CONFIG_DATA_PATH"
echo "MAPPROXY_CACHE_DATA_PATH=$MAPPROXY_CACHE_DATA_PATH"
echo "MAPPROXY_ALLOW_LISTING=$MAPPROXY_ALLOW_LISTING"

# Check if the .yaml file exists in /mapproxy/config/
if ! ls $MAPPROXY_CONFIG_DATA_PATH/*.yaml 1> /dev/null 2>&1; then
    echo "No mapproxy configuration file found, creating one..."
    mapproxy-util create -t base-config "$MAPPROXY_CONFIG_DATA_PATH"
else
    echo "Mapproxy configuration file found."
fi

# Start SSH service
echo "Starting SSH service..."
service ssh start

# Start Nginx with the appropriate configuration
echo "Starting Nginx..."
service nginx restart -g 'daemon off;' 

# Create uwsgi.conf with environment variables
echo "Creating uwsgi.conf with environment variables..."
envsubst < ./uwsgi.default.conf > ./uwsgi.conf

# Start MapProxy using uWSGI with the given configuration
echo "Starting MapProxy with $UWSGI_PROCESSES processes and $UWSGI_THREADS threads..."
/usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf &

# Keep the container running
while [ $done -eq 0 ]; do
  sleep 1
done