if [ -z "${MAPPROXY_DATA_DIR}" ]; then
    MAPPROXY_DATA_DIR=/mapproxy
fi
if [ -z "${MAPPROXY_CACHE_DIR}" ]; then
    MAPPROXY_CACHE_DIR=/mapproxy/cache_data
fi
if [ -z "${ALLOW_LISTING}" ]; then
	ALLOW_LISTING=True
fi
