
# Inception — User Documentation

This document explains, in clear and simple terms, how an end user or administrator
can use the Inception stack.

## 1. What services does this stack provide?

The infrastructure is made of three containers, each running one service:

- **NGINX** — the only entry point to the infrastructure. It listens on port `443`
  and only accepts secure (TLS) connections. Every request to the website passes
  through this container first.
- **WordPress (with php-fpm)** — the website itself (blog/CMS). It has no web server
  of its own; NGINX forwards requests to it internally.
- **MariaDB** — the database that stores all WordPress content (posts, users,
  settings). It cannot be reached from outside the infrastructure — only WordPress
  can talk to it, over the internal Docker network.

All three containers restart automatically if they crash, and all website files and
database data are kept in persistent storage, so nothing is lost when containers are
stopped or rebuilt.

## 2. Starting and stopping the project

Run these commands from the project root.

| Command       | What it does                                                        |
|---------------|----------------------------------------------------------------------|
| `make`        | Builds all images (if needed) and starts every container in the background |
| `make down`   | Stops and removes the containers, keeping your data intact           |
| `make status` | Shows the current status of every container                         |
| `make clean`  | Removes containers, images, and networks                             |
| `make fclean` | `clean` + deletes volumes and local data (⚠️ irreversible — this erases the website and database) |
| `make re`     | `fclean` followed by a fresh `make` (full rebuild from scratch)       |

**To start the project:** run `make`.
**To stop it without losing data:** run `make down`.
**To reset everything and start fresh:** run `make re`.

## 3. Accessing the website and the administration panel

Once the containers are running (see [Section 5](#5-checking-that-services-are-running-correctly) to confirm), open a browser and go to:

- **Website (homepage):** `https://maskour.42.fr`
- **Administration panel (WordPress dashboard):** `https://maskour.42.fr/wp-admin`

Since the TLS certificate is self-signed (not issued by a public certificate
authority), your browser will show a security warning on first visit. This is
expected — click through "Advanced" → "Proceed" (wording depends on your browser) to
continue.

Log into the administration panel with the WordPress admin credentials described in
the next section.

> Note: your machine needs a line mapping the domain to `127.0.0.1` in `/etc/hosts`
> for the URL to resolve, e.g. `127.0.0.1   maskour.42.fr`.

## 4. Locating and managing credentials

All credentials used by the stack (database access and WordPress admin/user
accounts) are defined in a single `.env` file at the root of the project. This file
is git-ignored and never committed to the repository.

Typical variables found in `.env`:

| Variable                        | Purpose                                              |
|----------------------------------|-------------------------------------------------------|
| `DOMAIN_NAME`                    | The domain used to access the site (e.g. `maskour.42.fr`) |
| `MYSQL_DATABASE`                 | Name of the WordPress database                        |
| `MYSQL_USER` / `MYSQL_PASSWORD`  | Credentials for the WordPress database user            |
| `MYSQL_ROOT_PASSWORD`            | Root password for the MariaDB server                   |
| `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` | Login for the WordPress administration panel      |
| `WP_USER` / `WP_USER_PASSWORD`   | Login for a regular (non-admin) WordPress user         |

**To change a credential:** edit the value in `.env`, then run `make re` so the new
values are applied (editing `.env` alone does not affect already-running
containers).

**Never** commit `.env` to version control or share it publicly — it contains real
passwords for the database and admin account.

## 5. Checking that services are running correctly

### Are the containers up?

```bash
make status
```
or:
```bash
docker compose -f srcs/docker-compose.yml ps
```
You should see three containers (`nginx`, `wordpress`, `mariadb`) all showing `Up`
(or `healthy`, if healthchecks are configured). If any shows `Exited` or keeps
restarting, something went wrong during startup.

### Reading logs for a specific service
```bash
make logs
```
or:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```
Look near the end of the output for error messages — most startup issues (wrong
credentials, missing config, port conflicts) show up there clearly.

### Confirming the website itself works

- `https://maskour.42.fr` should show the WordPress homepage.
- `https://maskour.42.fr/wp-admin` should show the WordPress login form.
- A "database connection error" on the site usually means the `mariadb` container
  isn't up, or the credentials in `.env` don't match what the database was
  initialized with — if you changed `.env` after the first `make`, run `make re`.
