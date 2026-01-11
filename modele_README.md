*This project has been created as part of the 42 curriculum by afodil-c.*

## Description

Inception is a system administration project that uses Docker to set up a small infrastructure composed of different services. The goal is to virtualize several Docker images in a personal virtual machine, learning containerization and orchestration concepts.

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

- **Base image**: Debian Bookworm (stable)
- **TLS**: Self-signed certificate with TLSv1.3
- **Database**: MariaDB with dedicated user for WordPress
- **Secrets**: Docker secrets for sensitive data (passwords)
- **Volumes**: Named volumes mapped to host directories for persistence

### Comparisons

#### Virtual Machines vs Docker

| Virtual Machines | Docker |
|------------------|--------|
| Full OS per VM | Shared host kernel |
| Heavy resource usage | Lightweight |
| Slow startup | Fast startup |
| Complete isolation | Process-level isolation |
| Hypervisor required | Docker engine only |

#### Secrets vs Environment Variables

| Secrets | Environment Variables |
|---------|----------------------|
| Stored in files, mounted at runtime | Visible in container config |
| Not exposed in logs or inspect | Can leak in logs |
| For sensitive data (passwords) | For non-sensitive config |
| Accessible via /run/secrets/ | Accessible via $VAR |

#### Docker Network vs Host Network

| Docker Network | Host Network |
|----------------|--------------|
| Isolated network namespace | Uses host network directly |
| Containers communicate by name | No network isolation |
| Port mapping required | No port mapping needed |
| More secure | Less secure |

#### Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|----------------|-------------|
| Managed by Docker | Direct host path |
| Portable | Host-dependent |
| Better for production | Good for development |
| Named and reusable | Explicit path required |

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Virtual Machine (recommended)
- Add `afodil-c.42.fr` to `/etc/hosts` pointing to `127.0.0.1`

### Installation and Execution

```bash
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
