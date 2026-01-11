# Developer Documentation

## Setting Up the Environment from Scratch

### Prerequisites

- Docker Engine (20.10+)
- Docker Compose (v2+)
- Make
- Virtual Machine (recommended for 42 evaluation)

### Host Configuration

Add the domain to `/etc/hosts`:

```bash
sudo sh -c 'echo "127.0.0.1 afodil-c.42.fr" >> /etc/hosts'
```

### Configuration Files

The project uses two types of configuration:

#### 1. Environment Variables (`srcs/.env`)

Generated automatically by `make env`. Contains:

```
DB_NAME=wordpress
DB_ADMIN_NAME=afodil-c
DOMAIN=afodil-c.42.fr
WP_TITLE=Inception
WP_ADMIN_NAME=afodil-c
WP_ADMIN_EMAIL=afodil-c@student.42.fr
WP_USER_NAME=user42
WP_USER_EMAIL=user42@student.42.fr
```

#### 2. Secrets (`secrets/`)

Created interactively by `make env`. Contains password files:

```
secrets/
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
└── wp_user_password.txt
```

## Building and Launching the Project

### Using Makefile

| Command | Description |
|---------|-------------|
| `make` | Build and start everything |
| `make env` | Create .env and secrets only |
| `make build` | Build Docker images |
| `make up` | Start containers |
| `make down` | Stop containers |
| `make logs` | Follow container logs |
| `make clean` | Stop and remove containers |
| `make fclean` | Full cleanup (data, volumes, secrets) |
| `make re` | Rebuild from scratch |

### Using Docker Compose Directly

```bash
cd srcs
docker compose up -d --build
docker compose down
docker compose logs -f
```

## Managing Containers and Volumes

### Containers

```bash
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

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect mariadb
docker volume inspect wordpress

# Remove volumes (data loss!)
docker volume rm mariadb wordpress
```

### Networks

```bash
# List networks
docker network ls

# Inspect network
docker network inspect inception
```

## Data Storage and Persistence

### Volume Locations

Data persists in `/home/afodil-c/data/`:

| Path | Content |
|------|---------|
| `/home/afodil-c/data/mariadb/` | Database files |
| `/home/afodil-c/data/wordpress/` | WordPress files (themes, plugins, uploads) |

### How Persistence Works

1. Docker named volumes are configured with `driver_opts` to bind to host directories
2. When containers restart, they mount the same directories
3. Data survives container recreation

### Backup

```bash
# Backup database
docker exec mariadb mysqldump -u root -p wordpress > backup.sql

# Backup WordPress files
cp -r /home/afodil-c/data/wordpress ./wordpress_backup
```

### Restore

```bash
# Restore database
docker exec -i mariadb mysql -u root -p wordpress < backup.sql

# Restore WordPress files
cp -r ./wordpress_backup/* /home/afodil-c/data/wordpress/
```

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
