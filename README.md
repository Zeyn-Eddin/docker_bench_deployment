# This script is still incomplete and under development
There are expected to be issues and recommendations are welcome. 

---

# Deploy Frappe Benches Using Docker
A shell script that simplifies the deployment of Dockerized Frappe benches by guiding users through configuration and Docker Compose file generation.

Running main_deploy.sh creates a dedicated directory under `~/deployments` to store bench-specific configurations, builds a custom Docker image with your custom apps, generates a .env file, and interactively lets you choose from available overrides to assemble a complete Docker compose YAML file. Once generated, deploy with `docker compose -f bench_name.yaml up -d` or import the file into Portainer for web-based container management.

---

# Features
- Interactive setup to simply a multi-step deployment process.
- Creates a folder in `~/deployments` to store all bench-specific configurations.
- Using a base image, generates a custom Frappe image with your custom apps by adding their git repo links and branch when prompted.
- Lets you select from available override templates, with the ability to add more functions to `overrides` directory.
- Output compose file can be used via CLI or imported into Portainer.

---

# Required Prerequisites
- Docker and Docker compose. To install Docker, please refer to the [official installation guide](https://docs.docker.com/engine/install/)
- Traefik to manage web traffic for the containers. To setup Traefik, please refer to [Frappe's documentation](https://github.com/frappe/frappe_docker/blob/main/docs/single-server-example.md)
- Building a Frappe image to serve as a base image. To build a Frappe image please refer to [Frappe's documentation](https://github.com/frappe/frappe_docker/blob/main/docs/container-setup/02-build-setup.md). Note: only to Build the image section is required

---

# Usage
Clone the repository
```declarative
git clone https://github.com/Zeyn-Eddin/docker_bench_deployment
cd docker_bench_deployment
```

To run the script
```declarative
./main_deploy.sh
```
- Use `--bench-name <name_of_bench>` to skip the initial `Enter the name of your Frappe bench: ` prompt 

