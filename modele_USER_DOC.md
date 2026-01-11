# User Documentation

## Services Provided

This stack provides a complete WordPress website with:

| Service | Description | Port |
|---------|-------------|------|
| NGINX | Web server with HTTPS | 443 |
| WordPress | Content management system | - |
| MariaDB | Database server | - |

## Starting and Stopping the Project

### Start

```bash
make
```

This command will:
1. Create the `.env` configuration file
2. Prompt you for passwords (database, WordPress admin, WordPress user)
3. Build all Docker images
4. Start all containers

### Stop

```bash
make down
```

Stops all containers but preserves data.

### Full Stop and Cleanup

```bash
make fclean
```

Stops containers and removes all data, volumes, secrets, and configuration.

## Accessing the Website

### Main Website

Open your browser and navigate to:

```
https://afodil-c.42.fr
```

Note: You will see a certificate warning because the SSL certificate is self-signed. Accept the warning to proceed.

### Administration Panel

Access the WordPress admin panel at:

```
https://afodil-c.42.fr/wp-admin
```

Login with:
- **Username**: afodil-c (or the login configured)
- **Password**: The password you entered during setup (WordPress admin password)

## Managing Credentials

### Location

Passwords are stored in the `secrets/` directory:

| File | Content |
|------|---------|
| `secrets/db_password.txt` | Database user password |
| `secrets/db_root_password.txt` | Database root password |
| `secrets/wp_admin_password.txt` | WordPress admin password |
| `secrets/wp_user_password.txt` | WordPress regular user password |

### Changing Passwords

To change passwords:

1. Stop the project: `make down`
2. Edit the corresponding file in `secrets/`
3. Remove data: `make fclean`
4. Restart: `make`

Note: Changing passwords requires recreating the database.

## Checking Services Status

### View Running Containers

```bash
docker ps
```

You should see 3 containers: `nginx`, `wordpress`, `mariadb`

### View Logs

```bash
make logs
```

Or for a specific service:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Health Check

MariaDB has a built-in health check. To verify:

```bash
docker inspect mariadb | grep -A 5 "Health"
```

### Test Website

```bash
curl -k https://afodil-c.42.fr
```

Should return HTML content.
