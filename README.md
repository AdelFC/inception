*This project has been created as part of the 42 curriculum by afodil-c.*

## Description

Inception is a system administration project that uses Docker to set up an infrastructure composed of different services. The goal is to virtualize several Docker images in a personal virtual machine, learning containerization and orchestration concepts.

The infrastructure includes:
- NGINX web server with TLS
- WordPress with php-fpm
- MariaDB database

## Project Description

### Docker Usage

This project uses Docker and Docker Compose to create isolated containers for each service. Each service runs in its own container, built from custom Dockerfiles based on Debian Bookworm.

### Architecture

```
Client :443 --> NGINX --> :9000 --> WordPress --> :3306 --> MariaDB
                 |                      |
            wordpress volume       mariadb volume
```

### Design Choices

- Debian Bookworm is used as base image because it is stable
- TLS uses a self-signed certificate with TLSv1.3
- MariaDB has a dedicated user for WordPress
- Docker secrets are used for sensitive data like passwords
- Named volumes are mapped to host directories for persistence

### Comparisons

#### Virtual Machines vs Docker

Virtual machines run a full OS per VM, use heavy resources, have slow startup but provide complete isolation and require a hypervisor. Docker shares the host kernel, is lightweight, starts fast, provides process-level isolation and only needs the Docker engine.

#### Secrets vs Environment Variables

Secrets are stored in files and mounted at runtime, they are not exposed in logs or inspect commands, and are accessible via /run/secrets/. They are used for sensitive data like passwords. Environment variables are visible in container config, can leak in logs, and are accessible via $VAR. They are used for non-sensitive configuration.

#### Docker Network vs Host Network

Docker network creates an isolated network namespace where containers communicate by name and port mapping is required. This is more secure. Host network uses the host network directly with no isolation and no port mapping needed, but is less secure.

#### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker, portable, better for production and are named and reusable. Bind mounts use a direct host path, are host-dependent, good for development and require an explicit path.

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Virtual Machine (recommended)
- Add `afodil-c.42.fr` to `/etc/hosts` pointing to `127.0.0.1`

### Installation and Execution

```
# Build and start all services
make

# Stop services
make down

# View logs
make logs

# Full cleanup (removes all data)
make fclean

# Rebuild from scratch
make re
```

### Access

- Website: https://afodil-c.42.fr
- Admin panel: https://afodil-c.42.fr/wp-admin

## Resources

### Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

### AI Usage

AI tools were used for:
- Reviewing Dockerfile best practices
- Debugging entrypoint scripts
- Comparing configuration approaches
- Documentation structure

All AI-generated content was reviewed, tested, and adapted to fit the project requirements.
