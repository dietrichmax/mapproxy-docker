import requests
import sys

# Health check URL for MapProxy
url = "http://localhost:80/health"

try:
    response = requests.get(url, timeout=10)
    # Check if response is successful
    if response.status_code == 200:
        print("Health check passed")
        sys.exit(0)  # Success
    else:
        print(f"Health check failed: {response.status_code}")
        sys.exit(1)  # Failure
except requests.exceptions.RequestException as e:
    print(f"Health check failed: {e}")
    sys.exit(1)  # Failure
