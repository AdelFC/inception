# User Documentation

## Services Provided

This project provides a complete WordPress website with three services:
- NGINX is the web server with HTTPS on port 443
- WordPress is the content management system
- MariaDB is the database server

## Starting and Stopping the Project

### Start

```
make
```

This command will create the `.env` configuration file, ask you for passwords (database, WordPress admin, WordPress user), build all Docker images and start all containers.

### Stop

```
make down
```

Stops all containers but preserves data.

### Full Stop and Cleanup

```
make fclean
```

Stops containers and removes all data, volumes, secrets and configuration.

## Accessing the Website

### Main Website

Open your browser and navigate to `https://afodil-c.42.fr`

There is a certificate warning because the SSL certificate is self-signed. Accept the warning to proceed.

### Administration Panel

Access the WordPress admin panel at `https://afodil-c.42.fr/wp-admin`

Login with your username (afodil-c configured) and the password you entered during setup.

## Managing Credentials

### Location

Passwords are stored in the `secrets/` directory:
- `secrets/db_password.txt` contains the database user password
- `secrets/db_root_password.txt` contains the database root password
- `secrets/wp_admin_password.txt` contains the WordPress admin password
- `secrets/wp_user_password.txt` contains the WordPress regular user password

### Changing Passwords

To change passwords, stop the project with `make down`, edit the corresponding file in `secrets/`, remove data with `make fclean`, then restart with `make`.

Changing passwords requires recreating the database.

## Checking Services Status

### View Running Containers

```
docker ps
```

You should see 3 containers: nginx, wordpress, mariadb

### View Logs

```
make logs
```

Or for a specific service:

```
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Health Check

MariaDB has a built-in health check. To verify:

```
docker inspect mariadb
```

### Test Website

```
curl -k https://afodil-c.42.fr
```

Should return HTML content.
