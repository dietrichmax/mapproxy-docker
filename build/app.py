import os
from mapproxy.multiapp import make_wsgi_app
# # uncomment the following lines for logging
# # create a log.ini with `mapproxy-util create -t log-ini`
# from logging.config import fileConfig
# import os.path
# fileConfig(r'/mapproxy/config/log.ini', {'here': os.path.dirname(__file__)})

def get_bool_env(var_name):
    """
    Retrieves an environment variable and converts it to a boolean value.
    It treats 'true' (case insensitive) as True, and anything else as False.
    
    :param var_name: Name of the environment variable.
    :param default: Default value if the environment variable is not set or invalid.
    :return: Boolean value corresponding to the environment variable.
    """
    value = os.getenv(var_name).strip().lower()
    return value == "true"

# Access environment variables
mapproxy_config_path = os.getenv("MAPPROXY_CONFIG_DATA_PATH")
mapproxy_allow_listing = get_bool_env("MAPPROXY_ALLOW_LISTING")


application = make_wsgi_app(mapproxy_config_path, allow_listing=mapproxy_allow_listing)

