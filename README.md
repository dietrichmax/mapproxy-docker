<div align="center">

# Multi-MapProxy Docker Image 🗺️🐳

**Docker image for [MapProxy](https://mapproxy.org/)**

[![☕ Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-Support-yellow?logo=buymeacoffee)](https://buymeacoffee.com/mxdcodes)  ![🚀 Version](https://img.shields.io/github/v/release/dietrichmax/mapproxy-docker)  [![📦 Docker Pulls](https://img.shields.io/docker/pulls/mxdcodes/mapproxy-docker?label=Docker%20Pull)](https://hub.docker.com/r/mxdcodes/mapproxy-docker)  [![🛠 Build Status](https://github.com/dietrichmax/mapproxy-docker/actions/workflows/docker_build.yml/badge.svg)](https://github.com/dietrichmax/mapproxy-docker/actions/workflows/docker_build.yml)  ![📝 License: Apache-2.0](https://img.shields.io/github/license/dietrichmax/mapproxy-docker)

</div>

## 📌 Overview

This repository provides a Docker image for [MapProxy](https://mapproxy.org/) with Nginx, a powerful tile cache and web mapping service.  

⚠ **Note**: This Docker image is designed to run on **Azure App Service**. Do not use this image for any other public service without SSH modifications unless you are sure you want to!  

---

## 🚀 How to Use

### 🏗️ Build the Docker Image  
```bash
docker build -t mapproxy-docker .
```

### ▶️ Run the Docker Image  
```bash
docker run -p 80:80 -p 2222:2222 --name mapproxy mapproxy-docker
```
This will start the MapProxy service and expose it on port `80`. SSH will be available on port `2222`.

### 🌍 Access the Application  
- Open a browser and navigate to:  
  👉 **`http://localhost`**  

- SSH into the container using:  
  ```bash
  ssh root@localhost -p 2222
  ```

### ⚙️ Configuration Files  
- The **MapProxy configuration files** are located in `/mapproxy/config`.  
- If no `.yaml` configuration file is found, one will be **created automatically** using `mapproxy-util`.  

---

## ⚙️ Environment Variables Configuration

You can configure the following environment variables to customize the behavior of the MapProxy Docker image:

| Environment Variable       | Description                                                                                                  | Default Value            |
|------------------------------|------------------------------------------------------------------------------------------------------------|--------------------------|
| `MAPPROXY_CONFIG_DATA_PATH`  | Path to the **MapProxy configuration** directory where `.yaml` files are located.                          | `/mapproxy/config`       |
| `MAPPROXY_CACHE_DATA_PATH`   | Path to the **MapProxy cache** directory.                                                                  | `/mapproxy/cache_data`   |
| `MAPPROXY_ALLOW_LISTING`     | Determines if the `/config` directory should be **publicly listed** (`True` or `False`, case-insensitive). | `False`                  |

---

## 📂 Files in the Image

- 🗺️ **MapProxy Application**: Located in `/mapproxy/app.py`  
- 🛠 **Start Script**: `/mapproxy/start.sh` to initialize **MapProxy, Nginx, and SSH**.  
- 📜 **Nginx Configuration**: `/etc/nginx/sites-enabled/default` for serving the application.  
- 🔑 **SSH Configuration**: `/etc/ssh/sshd_config` for SSH access.  

---