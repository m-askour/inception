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
---------------------------------this is the other to do ----------------------------------------------------------------------------------
Will actually break the evaluation

1. MariaDB entrypoint (database.sh) — will crash on every start
You launch mysqld in the background to do the init, but you never stop it before the final exec mysqld .... The second mysqld will try to bind the same socket/port the first one already holds and fail. You need to shut down the first instance before the final exec:

bash
mysqladmin --socket=/var/run/mysqld/mysqld.sock shutdown
wait "$pid"
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock --skip-networking=0

(also note: you build /tmp/init.sql but only apply it via --init-file on the second mysqld — with the fix above that's fine, it'll run once on that final start.)

2. WordPress is never actually installed (instll_wordPress.sh)
This script only copies wp-config-sample.php and seds in DB creds — it never runs the actual WordPress install (creating tables, the admin user, site URL, etc.). As written, the first visit to https://login.42.fr will show the WordPress installation wizard, which the subject explicitly forbids ("you shouldn't see the WordPress Installation page") — that's an instant evaluation stop.

You need wp-cli in the wordpress image and something like:

bash
if ! wp core is-installed --allow-root; then
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --role=author --user_pass="${WP_USER_PASSWORD}" --allow-root
fi

Remember the admin username must not contain "admin"/"Admin" (subject is explicit about this), and you need a second, non-admin user to be able to leave a comment as required.

3. Base image: FROM debian:bullseye is not the penultimate stable release
I checked current Debian status: as of now (Aug 2026) trixie (13) is stable and bookworm (12) is the penultimate stable — bullseye (11) is oldoldstable, LTS ending this month. The subject requires the penultimate stable, so this Dockerfile should be FROM debian:bookworm, and (once I can see them) the nginx/wordpress Dockerfiles need to match. This also means your PHP setup needs revisiting — php7.4 isn't in bookworm's repos (default there is php8.2), so instll_wordPress.sh's hardcoded php-fpm7.4 binary path and /etc/php/7.4/fpm/pool.d/www.conf path will need updating too.

🟠 Will likely cause real problems

4. Conflicting/broken nginx config — unclear which one actually runs
You have three different things trying to define the nginx config:

default.conf — wraps a server {} block inside events {}/http {}. If this file lands in /etc/nginx/conf.d/ (included from the main http block), that's a nested http block, which is an nginx syntax error, container won't start.
nginx.conf — a full config with its own server block, referencing cert paths (/etc/nginx/certs/www.example.com.crt) that don't match what TSL-config.sh actually generates (/etc/ssl/certs/nginx-selfsigned.crt). Also has a port 80 → 443 redirect server block, which isn't harmful given you only publish 443, but it's dead code that adds confusion.
TSL-config.sh — generates its own cert and overwrites /etc/nginx/conf.d/default.conf at container startup with yet another version.

Pick one strategy. I'd suggest: drop the static default.conf and nginx.conf files, keep TSL-config.sh as the single source of truth (cert generation + config write at container start), and have it become the container's CMD/entrypoint via the Dockerfile.

5. Orphaned init.sql with plaintext hardcoded credentials
This file creates 'user'@'%' IDENTIFIED BY 'password' — it looks unused (superseded by database.sh's dynamically-generated init file) but if it's still sitting in your git repo, this is exactly the kind of thing the preliminary check is looking for: "credentials... available in the git repository and outside of secrets files" → automatic 0. Delete it, or confirm nothing copies it into an image.

🟡 Worth double-checking, not visible from these files
Directory structure: subject requires a srcs/ folder at repo root and a Makefile at the root — you didn't upload either, make sure they're actually there.
README.md / USER_DOC.md / DEV_DOC.md: also not uploaded — missing/empty = instant stop per the grading sheet, worth a final check on content and the exact required first line format for README.
secrets files (../secrets/*.txt): make sure they're .gitignore'd and not committed.
✅ What looks fine
docker-compose.yml: no network: host, no links:, a proper bridge network, image names match service names, volumes correctly bind to /home/maskour/data/..., secrets used properly instead of plaintext env vars for passwords.
Wait-loops (until mysqladmin ping..., until mysqladmin ping -h...) are conditional, not infinite — fine per the rules.
TSL-config.sh and the final execs in general correctly run in foreground, no backgrounded daemons left dangling in the final process.

Send me the nginx and wordpress Dockerfiles (with different filenames this time) and I can finish the review properly, especially to confirm the PHP/base-image consistency and how the nginx configs actually get wired together

-------------------------------------this is anout docker files ---------------------------------\
This resolves issue #4 from before — you only actually copy TSL-config.sh into the image, nothing else. default.conf and nginx.conf (the standalone files you uploaded earlier) aren't referenced anywhere in this Dockerfile, so they're just dead files sitting in your nginx/ folder, unused. TSL-config.sh is the real source of truth: it generates the cert and writes /etc/nginx/conf.d/default.conf at container startup, then runs nginx -g "daemon off;" in the foreground. That part is clean and correct.

My recommendation: delete default.conf and nginx.conf from your nginx/ build context. They're not wrong exactly, just noise — and if a grader or your future self opens that folder, unused/conflicting config files invite exactly the kind of "explain this" question you don't want mid-defense.

🔴 Still outstanding
FROM debian:bullseye — same issue as the MariaDB Dockerfile: bullseye is oldoldstable now. Should be debian:bookworm (the current penultimate stable), consistently across all three Dockerfiles.
One more thing worth checking here: this Dockerfile doesn't install any default nginx.conf either — it relies entirely on the base Debian nginx package's default /etc/nginx/nginx.conf, which already has an http {} block that does include /etc/nginx/conf.d/*.conf;. That's exactly right for how TSL-config.sh writes its default.conf — so functionally this should work correctly. Just confirm on a real build that the base Debian nginx package's default main config does include conf.d/*.conf (it does on Debian's stock nginx package, but worth eyeballing once you rebuild on bookworm).

Once you send the wordpress Dockerfile too, I can close the loop on the PHP-version consistency question (item #3 from before).

Dockerfile

this the is the wordpress dockerfile

Check wordpress Dockerfile
Check wordpress Dockerfile

That confirms it — now I have the full picture, and it's consistent with what I flagged before.

🔴 Confirmed issues

1. debian:bullseye again (3rd Dockerfile, same problem)
All three of your images build on bullseye. Needs to move to debian:bookworm across the board.

2. php7.4 — tied directly to the base image
php7.4* packages exist in bullseye's repos, which is exactly why this was picked — but they're not in bookworm's repos (bookworm ships php8.2 by default). So the moment you fix issue #1, this line breaks:

php7.4 php7.4-fpm php7.4-mysql php7.4-cli php7.4-mbstring php7.4-gd

needs to become:

php8.2 php8.2-fpm php8.2-mysql php8.2-cli php8.2-mbstring php8.2-gd

And correspondingly in instll_wordPress.sh, update:

/etc/php/7.4/fpm/pool.d/www.conf → /etc/php/8.2/fpm/pool.d/www.conf
exec /usr/sbin/php-fpm7.4 -F → exec /usr/sbin/php-fpm8.2 -F

3. No wp-cli installed — this is the missing piece for the install issue I flagged earlier
This Dockerfile never installs wp-cli, which is why instll_wordPress.sh can't actually run wp core install. Add it to the build:

dockerfile
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

Then in instll_wordPress.sh, after the wp-config.php sed block, add the actual install + second user (using --allow-root since the container runs as root here):

bash
if ! wp core is-installed --allow-root; then
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author --user_pass="${WP_USER_PASSWORD}" --allow-root
fi

You'll need to add WP_ADMIN_USER, WP_ADMIN_PASSWORD, WP_ADMIN_EMAIL, WP_USER, WP_USER_EMAIL, WP_USER_PASSWORD to your .env/secrets and pass them through in docker-compose.yml the same way you did WORDPRESS_DB_PASSWORD_FILE (admin password should go through a secret file too, not a plain env var). And double check WP_ADMIN_USER doesn't contain "admin"/"Admin" anywhere in it.

4. Minor: wget is installed but never used — you only use curl. Harmless, but drop it if you want a leaner image.

Where things stand

Of the four blocking issues I found across your setup, this Dockerfile confirms/explains two of them (php version being coupled to the OS version, and wp-cli being the missing link for a real WordPress install). The remaining fixes to apply everywhere:

Switch all 3 FROM debian:bullseye → debian:bookworm
Update php7.4 → php8.2 (Dockerfile + instll_wordPress.sh paths)
Add wp-cli + actual wp core install / wp user create calls
Fix the MariaDB entrypoint background-process bug (database.sh)
Delete the unused default.conf, nginx.conf, and init.sql files
Confirm srcs/, Makefile, README.md, USER_DOC.md, DEV_DOC.md are present and correctly formatted at repo root

Once you've made these changes, if you rebuild and it still throws errors, feel free to paste the actual docker compose up output and I can help debug from ther
