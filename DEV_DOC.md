# Developer Documentation

## Setting Up the Environment from Scratch

### Prerequisites

- Docker Engine (20.10+)
- Docker Compose (v2+)
- Make
- Virtual Machine (recommended for 42 evaluation)

### Configuration Files

The project uses two types of configuration.

#### 1. Environment Variables (`srcs/.env`)

Generated automatically by `make env`. Contains database name, admin name, domain, WordPress title, admin email and user email.

#### 2. Secrets (`secrets/`)

Created interactively by `make env`. Contains four password files: db_password.txt, db_root_password.txt, wp_admin_password.txt and wp_user_password.txt.

## Building and Launching the Project

### Using Makefile

- `make` builds and starts everything
- `make env` creates .env and secrets only
- `make build` builds Docker images
- `make up` starts containers
- `make down` stops containers
- `make logs` follows container logs
- `make clean` stops and removes containers
- `make fclean` does a full cleanup including data, volumes and secrets
- `make re` rebuilds from scratch

### Using Docker Compose Directly

```
cd srcs
docker compose up -d --build
docker compose down
docker compose logs -f
```

## Managing Containers and Volumes

### Containers

```
# List running containers
docker ps

# Access container shell
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

# Restart a specific container
docker restart wordpress
```

### Volumes

```
# List volumes
docker volume ls

# Inspect volume
docker volume inspect mariadb
docker volume inspect wordpress

# Remove volumes (data loss!)
docker volume rm mariadb wordpress
```

### Networks

```
# List networks
docker network ls

# Inspect network
docker network inspect inception
```

## Data Storage and Persistence

### Volume Locations

Data persists in `/home/afodil-c/data/`. The mariadb folder contains database files and the wordpress folder contains WordPress files like themes, plugins and uploads.

### How Persistence Works

Docker named volumes are configured with driver_opts to bind to host directories. When containers restart, they mount the same directories. Data survives container recreation.

## Project Structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                    # Git ignored
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env                    # Git ignored
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── entrypoint.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── entrypoint.sh
```
