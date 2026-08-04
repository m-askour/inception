Step 0
Create docker-compose.yml
Step 1
Create Dockerfile for:
nginx
wordpress
mariadb
docker network

Step 2 --=> this for nginx
Configure TLS certificate (what's the defrence between the SSL"Secure Sockets Layer" and the TLS"Transport Layer Security")
openssl req -x509



Step 3 this is for --=> mariadb
Configure MariaDB database
Create:
wordpress database
user
admin



Step 4
Install WordPress
Configure:
wp-config.php




Step 5
Configure NGINX reverse proxy



Step 6
Create volumes
/home/login/data


Step 7
Run project
make


## this day is for the mariadb and wordpress


1- maryadb mysql creat database user
- creat BD
- creat user 
- grant privileges

in docker file the first is mamage the the mariadb continer 
 
## this day we work with wordpress and php

1- how the wordpress connects to the db 
2- wp-cofig.php
3- php-fpm concept



## this day for nginx + ssl


I read through everything — including checking the actual files on disk (a few things got overwritten, more on that below). Let me confirm current Debian release info since your Dockerfile pins a version, then give you the full review.

Assessed Debian version relevance and stability considerations
Assessed Debian version relevance and stability considerations

Good — confirmed: Debian 13 "trixie" is current stable, so the penultimate stable is Debian 12 "bookworm", not bullseye. Your Dockerfile is one version too old.

Now the review. First, an important heads-up: you uploaded three files all named Dockerfile (nginx, wordpress, mariadb), and since they share the same filename, each upload overwrote the previous one — only the mariadb Dockerfile survived. I can't check your nginx and wordpress Dockerfiles because they weren't actually preserved. Please re-upload those two with the files zipped or renamed (e.g. Dockerfile.nginx, Dockerfile.wordpress) so I can check them too.

Here's what I found in what I could check:

🔴 Critical issues

1. init.sql has hardcoded plaintext credentials

sql
CREATE USER 'user'@'%' IDENTIFIED BY 'password';

The subject is explicit: "Any credentials, API keys, or passwords found in your Git repository ... will result in project failure." This file isn't even used by database.sh (which creates the DB/user from env vars itself), so it's dead code that could fail your whole project for nothing. Delete init.sql, or if you want to keep the pattern, generate it at runtime with envsubst from your .env values — never commit literal values.

2. WordPress doesn't actually look installed
instll_wordPress.sh only edits wp-config.php (DB connection) and launches php-fpm. I don't see any wp core install, wp user create, or WP-CLI calls anywhere. The subject requires WordPress to be installed and configured, including two DB users, one admin (with a non-admin-like username). Right now, visiting the site for the first time would likely just show the WordPress install wizard instead of a ready site. You need something like:

bash
wp core install --url=$DOMAIN_NAME --title="..." \
  --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL
wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD

using wp-cli (downloaded in the Dockerfile). Double check your admin username doesn't contain "admin"/"administrator" per the subject's rule.

3. Debian version
FROM debian:bullseye (11) is two releases behind current stable (13, trixie). Penultimate stable is bookworm (12). Use FROM debian:bookworm (same for whichever service uses debian, if any).

🟡 Things to fix

4. docker-compose.yml

No image: key set — nothing guarantees the built image name equals the service name (subject: "Each Docker image must have the same name as its corresponding service"). Add image: nginx, image: mariadb, image: wordpress explicitly.
ports: "8443:443" — the subject wants NGINX as the entrypoint via port 443. Mapping the host side to 8443 is risky to a strict grader; map "443:443" instead.
No secrets: section — not strictly mandatory (subject says "strongly recommended"), but you should at least mention in your README why you chose .env over secrets, since that comparison is a required README section.

5. Nginx config confusion
You have three different places defining the server block:

nginx.conf — has its own hardcoded server {} on 443, referencing certs at /etc/nginx/certs/www.example.com.crt that nothing generates.
default.conf — mostly commented out, ends with include /etc/nginx/conf.d/*.conf; (looks like it's meant to be your main nginx.conf, not a vhost file).
TSL-config.sh — generates the self-signed cert at container start and writes its own /etc/nginx/conf.d/default.conf with yet another server block.

This is redundant and confusing, and depending on what your (missing) nginx Dockerfile actually COPYs where, you risk two server blocks fighting over port 443 or dead config files sitting unused. Pick one approach:

Either bake the cert + static config at build time (simpler, matches "config as code" better for grading), or
Generate everything at runtime via TSL-config.sh (what you're currently doing) — in which case delete nginx.conf's embedded server block and default.conf's leftover commented junk, and just keep a minimal nginx.conf with the http {} wrapper + include conf.d/*.conf;, since TSL-config.sh writes the real vhost.

Don't keep both — clean it down to one clear path.

6. TSL-config.sh typo — should be TLS-config.sh (cosmetic, but worth fixing for the defense).

7. mysqld_safe pattern in database.sh
Not wrong, but double check it survives as a sane PID 1. Your logic (start in background → init DB → shutdown → wait → exec mysqld_safe again as foreground) works, but it's a bit fragile. Consider just checking if the data dir is already initialized, and if not, running mysql_install_db then directly exec mysqld_safe once — no need to start/stop it twice.

8. No MYSQL_ROOT_PASSWORD handling
Not fatal per the subject text, but graders commonly expect the root account to be secured too (right now it's passwordless, socket-only). Worth adding for security completeness and for your README's secrets discussion.

🟢 Fine as-is
mariadb.conf — minimal but functional.
Named volumes with bind-mount driver_opts pointing to /home/maskour/data/... — correctly satisfies "named volumes, no bind mounts" (compose named volumes with a bind-type driver are still Docker named volumes, this is the standard 42 trick) and the /home/login/data path requirement.
Network is a custom bridge (inception), not host — correct.
restart: always on all three services — satisfies the crash-restart requirement.
No tail -f / sleep infinity / infinite loops anywhere — good, your entrypoints properly exec the real daemon as PID 1.

Next step: please resend the nginx and wordpress Dockerfiles (with distinct names or as a zip) — those are the ones I most need to check, especially to confirm the WP-CLI installation step and how nginx configs actually get placed.

