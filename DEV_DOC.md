
# Inception — Developer Documentation

This document describes how a developer can set up, build, launch, and manage the
Inception stack, and where its data lives. For end-user instructions (accessing the
site, credentials, health checks), see `USER_DOC.md`.

## 1. Setting up the environment from scratch

### Prerequisites

- A Linux-based machine or VM (the subject requires a VM for the mandatory part)
- Docker Engine
- Docker Compose (v2, invoked as `docker compose`)
- `make`
- `git`

Check they're installed:
```bash
docker --version
docker compose version
make --version
```

### Cloning the project

```bash
git clone <repo-url>
cd inception
```

### Configuration files

| File                              | Purpose                                                        |
|------------------------------------|-----------------------------------------------------------------|
| `Makefile`                        | Entry point for build/run/clean commands                        |
| `srcs/docker-compose.yml`         | Defines all services, networks, and volumes                     |
| `srcs/.env`                       | Environment variables consumed by `docker-compose.yml` and the Dockerfiles (domain name, DB name/credentials, WordPress admin/user info) |
| `srcs/requirements/<service>/Dockerfile` | Build instructions for each service's image               |
| `srcs/requirements/<service>/conf/` | Static configuration copied into each image at build time     |
| `srcs/requirements/<service>/tools/` | Entrypoint/setup scripts run at container startup             |

### Creating the `.env` file

`.env` is git-ignored and must be created manually before the first build. At
minimum it should define:
```
DOMAIN_NAME=maskour.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=change_me
MYSQL_ROOT_PASSWORD=change_me_too

WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=change_me
WP_ADMIN_EMAIL=admin@example.com

WP_USER=editor
WP_USER_PASSWORD=change_me
WP_USER_EMAIL=editor@example.com
```
Adjust variable names to whatever your `docker-compose.yml` and entrypoint scripts
actually reference. Never commit this file.

### Secrets

Where the subject requires actual **Docker secrets** (rather than plain environment
variables) for sensitive values such as database passwords:

1. Create the secret files (commonly under a git-ignored `secrets/` directory), one
   value per file, e.g. `secrets/db_password.txt`.
2. Declare them in `docker-compose.yml`:
   ```yaml
   secrets:
     db_password:
       file: ../secrets/db_password.txt
   ```
3. Reference them in the relevant service:
   ```yaml
   services:
     mariadb:
       secrets:
         - db_password
   ```
4. Inside the container, the value is available as a file at
   `/run/secrets/db_password` (not as an environment variable) — the container's
   entrypoint script should read the file rather than expecting a plain env var.

### Local DNS

Add a line to `/etc/hosts` so the domain resolves to the VM/local machine:
```
127.0.0.1   maskour.42.fr
```

## 2. Building and launching the project

The `Makefile` wraps `docker compose` so you don't need to type long commands
manually.

```bash
make
```
This target typically:
1. Ensures the host data directories exist (for the bind-mounted volumes).
2. Runs `docker compose -f srcs/docker-compose.yml up --build -d`, which:
   - Builds an image for each service from its `Dockerfile`.
   - Creates the custom bridge network defined in `docker-compose.yml`.
   - Creates the named volumes if they don't exist yet.
   - Starts a container per service, attached to the network and volumes, in
     dependency order (`depends_on`).

Equivalent raw command, if you want to bypass the Makefile while debugging:
```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

## 3. Managing containers and volumes

### Containers

| Command                                              | Purpose                                  |
|-------------------------------------------------------|-------------------------------------------|
| `docker compose -f srcs/docker-compose.yml ps`        | List container status                     |
| `docker compose -f srcs/docker-compose.yml logs -f <service>` | Follow logs for one service        |
| `docker compose -f srcs/docker-compose.yml restart <service>` | Restart a single service           |
| `docker compose -f srcs/docker-compose.yml stop`      | Stop containers without removing them     |
| `docker compose -f srcs/docker-compose.yml down`      | Stop and remove containers + network      |
| `docker exec -it <container> bash`                    | Open a shell inside a running container   |
| `docker inspect <container>`                          | View full config/state of a container     |

### Volumes

| Command                          | Purpose                                        |
|-----------------------------------|--------------------------------------------------|
| `docker volume ls`                | List all Docker volumes                          |
| `docker volume inspect <name>`    | Show a volume's mountpoint and metadata          |
| `docker compose -f srcs/docker-compose.yml down -v` | Stop containers **and** remove their volumes (⚠️ deletes persisted data) |

### Makefile shortcuts (recommended over raw commands above)

| Command       | Equivalent to                                                       |
|---------------|-----------------------------------------------------------------------|
| `make status` | `docker compose ... ps`                                              |
| `make down`   | `docker compose ... down` (containers/network removed, volumes kept) |
| `make clean`  | `down` + removes built images                                        |
| `make fclean` | `clean` + removes volumes and host data directories (irreversible)   |
| `make re`     | `fclean` then `make` (full rebuild from a clean state)                |

## 4. Where project data is stored and how it persists

Two categories of state need to survive container restarts/rebuilds:

- **MariaDB data** (databases, tables) — normally stored in `/var/lib/mysql` inside
  the `mariadb` container.
- **WordPress files** (core files, themes, plugins, uploads) — normally stored in
  `/var/www/html` inside the `wordpress` container, and also read by `nginx` to
  serve static assets.

Both are declared as **named volumes** in `docker-compose.yml` and bind-mounted to
fixed paths on the host (commonly under `/home/<login>/data/`), for example:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/maskour/data/mariadb
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/maskour/data/wordpress
```

```yaml
services:
  mariadb:
    volumes:
      - mariadb_data:/var/lib/mysql
  wordpress:
    volumes:
      - wordpress_data:/var/www/html
  nginx:
    volumes:
      - wordpress_data:/var/www/html
```

**Why this persists data:** the volume exists independently of any single container.
When a container is stopped, removed, or rebuilt (`make down`, `make clean`, or even
a full `docker compose up --build`), the volume itself is untouched — the next
container that mounts it sees the exact same files/database as before. Data is only
lost if the volume itself is explicitly removed, which is exactly what `make fclean`
does (`docker compose down -v` + removing the host data directories) — so that
command should be used deliberately, not as part of routine restarts.

To inspect where a volume actually lives on the host:
```bash
docker volume inspect mariadb_data
```
The `Mountpoint` field (or the `device` path you configured) shows the real
on-disk location of the data.
