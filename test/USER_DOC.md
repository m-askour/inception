*This project has been created as part of the 42 curriculum by maskour.*

# Inception

## Description

Inception is a system administration project whose goal is to learn the fundamentals of
Docker by building a small, production-like infrastructure entirely from containers.

Everything runs on a single virtual machine and is orchestrated with `docker-compose`.
Each service lives in its own container, built from a custom `Dockerfile` based on a
lightweight Linux image (no ready-made Docker Hub images for the services themselves,
as required by the subject), and every container is set to restart automatically in
case it crashes.

The stack is made of three mandatory services:

- **NGINX** — the only entry point to the infrastructure, exposed on port 443 and
  configured to accept only TLS (SSLv3/TLS 1.2/1.3) connections.
- **WordPress + php-fpm** — the website itself, served through NGINX and running
  without its own web server (only php-fpm listening internally).
- **MariaDB** — the database used by WordPress, isolated from the outside world and
  only reachable by the other containers on the internal Docker network.

Each service has its own dedicated container and its own `Dockerfile`, so the
infrastructure can be rebuilt from scratch with a single command.

## Instructions

### Requirements

- Docker
- Docker Compose
- `make`
- A `.env` file at the root of the project (see `srcs/.env.example` if provided) defining
  the domain name, database credentials references, and WordPress admin/user info.

### Setup

1. Add a line mapping your login's domain to `127.0.0.1` in `/etc/hosts`, e.g.:
   ```
   127.0.0.1   maskour.42.fr
   ```
2. Clone the repository and move into it:
   ```bash
   git clone <repo-url>
   cd inception
   ```
3. Build and start the whole infrastructure:
   ```bash
   make
   ```
4. Visit `https://maskour.42.fr` in your browser (accept the self-signed certificate).

### Useful commands

| Command       | Description                                                |
|---------------|------------------------------------------------------------|
| `make`        | Builds all images and starts the containers in background  |
| `make down`   | Stops and removes the containers                           |
| `make clean`  | Removes containers, images, and networks                   |
| `make fclean` | `clean` + removes volumes and local data (irreversible)    |
| `make re`     | `fclean` followed by a fresh `make`                        |
| `make status` | Displays the status of the containers                      |

## Resources

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress + php-fpm setup guides](https://wordpress.org/documentation/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- 42 Inception subject PDF (intranet)

**AI usage:** An AI assistant (Claude) was used to help draft and structure this
README.md file — organizing the required sections, wording the service descriptions,
and writing the Docker vs. VM / secrets / network / volumes comparisons below. No AI was
used to generate the Dockerfiles, docker-compose configuration, or any project source
code; those were written manually to comply with the subject's requirements.

## Project Description: Docker & Design Choices

The whole infrastructure is described declaratively in a single `docker-compose.yml`
file located in `srcs/`. Each service (NGINX, WordPress, MariaDB) is built from its own
`Dockerfile` under `srcs/requirements/<service>/`, starting from a minimal base image
and installing only what is strictly necessary. This keeps images small, makes the
build reproducible, and makes each container's responsibility explicit.

### Sources used

| Service   | Base image         | Notes                                                                         |
|-----------|--------------------|-------------------------------------------------------------------------------|
| NGINX     | `debian:bullseye`  | NGINX installed via `apt`, config copied in, TLS cert generated at build time |
| WordPress | `debian:bullseye`  | PHP + php-fpm installed via `apt`, WordPress core downloaded via `wp-cli`     |
| MariaDB   | `debian:bullseye`  | MariaDB server installed via `apt`, init script sets up the DB and users      |

*(Replace the base image and package sources above with whatever you actually used —
e.g. `alpine:3.19` and `apk` if that's your case.)*

No pre-built service images from Docker Hub (e.g. `nginx:latest`, `wordpress:latest`,
`mariadb:latest`) are used, as required by the subject — every image is built from a
generic OS base image plus the minimal set of packages needed for that service.

Key design choices:

- **One container, one role**: no supervisor process managing multiple services inside
  a single container; each container runs exactly one main process in the foreground
  (as required by Docker's process model).
- **Custom bridge network**: all containers communicate through a dedicated Docker
  network created by Compose, instead of relying on the host network or default bridge.
- **Persistent data via volumes**: WordPress files and the MariaDB database are stored
  on named Docker volumes bind-mounted to fixed paths on the host, so data survives
  container restarts and rebuilds.
- **Secrets for sensitive data**: database and WordPress credentials are not hardcoded
  in the Dockerfiles or committed to the repository; they are injected at runtime
  through environment variables (`.env`, git-ignored) and, where required by the
  subject, Docker secrets.
- **TLS-only exposure**: NGINX is the single entry point and only accepts HTTPS
  traffic, terminating TLS with a self-signed certificate generated at build time.

### Virtual Machines vs Docker

A **Virtual Machine** virtualizes an entire computer: it runs its own full guest
operating system (kernel included) on top of a hypervisor, which gives strong
isolation but comes with significant overhead in boot time, memory, and disk usage.

**Docker containers**, by contrast, share the host machine's kernel and only package
the application and its dependencies. This makes them much lighter and faster to start
(seconds instead of minutes), more efficient in resource usage, and easier to
reproduce and ship, at the cost of slightly weaker isolation than a full VM. For this
project, Docker was the natural choice since the goal is to isolate services (NGINX,
WordPress, MariaDB) from each other without the overhead of running three full
operating systems.

### Secrets vs Environment Variables

**Environment variables** are simple key/value pairs passed to a container at
startup. They are convenient, but they can leak: they are visible in `docker inspect`,
in the process environment, and often end up committed in `.env` files or CI logs if
not handled carefully. They are best suited for non-sensitive configuration (domain
names, ports, feature flags).

**Docker secrets** are designed specifically for sensitive data (passwords, API keys,
certificates). A secret is mounted as a read-only file inside the container's
filesystem (typically under `/run/secrets/`) instead of being exposed as an
environment variable, is encrypted at rest and in transit within a Swarm cluster, and
is not visible through `docker inspect`. In this project, secrets are used for
database and WordPress credentials, while environment variables are reserved for
non-sensitive configuration.

### Docker Network vs Host Network

With the **host network** mode, a container shares the host's network stack
directly: it uses the host's IP address and ports with no isolation, which is fast but
removes any network-level separation between the container and the host (and between
containers).

A custom **Docker (bridge) network**, as used in this project, gives each container
its own virtual network interface and IP address, isolated from the host and from
containers on other networks. Containers on the same Docker network can reach each
other by service name thanks to Docker's built-in DNS resolution, without exposing
their ports to the host or the outside world unless explicitly published. This is why
MariaDB, for instance, is never exposed on a host port — it is only reachable by
WordPress over the internal network.

### Docker Volumes vs Bind Mounts

**Bind mounts** map a specific path on the host filesystem directly into the
container. They are simple and give full visibility of the data on the host, but they
depend on the host's directory structure, offer less portability, and provide no
management layer (no easy way to list, back up, or migrate the data through Docker
itself).

**Docker volumes** are managed entirely by Docker: they live in a location controlled
by the Docker daemon, can be listed, inspected, and backed up with `docker volume`
commands, and are portable across environments since they aren't tied to a specific
host path. In this project, named volumes are used to persist WordPress files and the
MariaDB database, ensuring the data survives container recreation while staying
managed and inspectable through Docker's own tooling.
