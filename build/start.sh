#!/bin/bash
set -e

export UWSGI_PROCESSES=${UWSGI_PROCESSES:-$(nproc)}
export UWSGI_THREADS=${UWSGI_THREADS:-$(( $(nproc) * 2 ))}
export MAPPROXY_CONFIG_DATA_PATH="${MAPPROXY_CONFIG_DATA_PATH:-/mapproxy/config}"
export MAPPROXY_CACHE_DATA_PATH="${MAPPROXY_CACHE_DATA_PATH:-/mapproxy/cache_data}"
export MAPPROXY_ALLOW_LISTING=${MAPPROXY_ALLOW_LISTING:-false}

cd /mapproxy

echo "MAPPROXY_CONFIG_DATA_PATH=$MAPPROXY_CONFIG_DATA_PATH"
echo "MAPPROXY_CACHE_DATA_PATH=$MAPPROXY_CACHE_DATA_PATH"
echo "MAPPROXY_ALLOW_LISTING=$MAPPROXY_ALLOW_LISTING"

# Create default config if none exists
if ! ls "$MAPPROXY_CONFIG_DATA_PATH"/*.yaml 1>/dev/null 2>&1; then
    echo "No mapproxy configuration file found, creating one..."
    mapproxy-util create -t base-config "$MAPPROXY_CONFIG_DATA_PATH"
else
    echo "Mapproxy configuration file found."
fi

# Generate uwsgi.conf from template
echo "Creating uwsgi.conf with environment variables..."
envsubst < ./uwsgi.default.conf > ./uwsgi.conf

# Start nginx in daemon mode
echo "Starting Nginx..."
nginx

# Start uWSGI as PID 1 for proper signal handling
echo "Starting MapProxy with $UWSGI_PROCESSES processes and $UWSGI_THREADS threads..."
exec /usr/local/bin/uwsgi --ini /mapproxy/uwsgi.conf
