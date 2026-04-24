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




to do list so detail 
2. Docker Architecture
 Understand Docker basics (images, containers, volumes, networks)
 Plan infrastructure (Nginx + WordPress + MariaDB)
 Create docker-compose.yml
 Create custom Docker network
 Configure auto-restart for containers
🔹 3. MariaDB Container
 Create MariaDB Dockerfile
 Install MariaDB inside container
 Configure database
 Create database for WordPress
 Create 2 users:
 Admin user (NOT named "admin")
 Normal user
 Secure database (passwords via .env or secrets)
 Configure volume for database
🔹 4. WordPress Container
 Create WordPress Dockerfile
 Install PHP + php-fpm
 Download and configure WordPress
 Connect WordPress to MariaDB
 Configure WordPress users
 Configure volume for website files
🔹 5. NGINX Container
 Create Nginx Dockerfile
 Install Nginx
 Configure HTTPS (TLSv1.2 or TLSv1.3)
 Generate SSL certificate
 Configure reverse proxy to WordPress
 Open only port 443
 Block HTTP (port 80 optional redirect)
🔹 6. Volumes & Storage
 Create 2 Docker volumes:
 Database volume
 WordPress files volume
 Set path: /home/login/data
 Test data persistence
🔹 7. Networking
 Configure Docker network
 Connect all containers
 Test communication:
WordPress ↔ MariaDB
Nginx ↔ WordPress
🔹 8. Environment & Security
 Use .env for variables
 Remove passwords from Dockerfiles ❗
 Use Docker secrets (recommended)
 Secure credentials (ignore in Git)
🔹 9. Domain Configuration
 Set domain: login.42.fr
 Point domain to local IP
 Edit /etc/hosts
 Test access via browser
🔹 10. Makefile
 Create Makefile commands:
 make build
 make up
 make down
 make clean
 Link Makefile with docker-compose
🔹 11. Testing & Debugging
 Test all containers run correctly
 Test restart behavior
 Test website loading
 Test database connection
 Fix errors
🔹 12. Documentation (IMPORTANT)
README.md
 Project description
 How to run project
 Docker explanation
 Comparisons:
VM vs Docker
Volumes vs Bind mounts
Network vs Host
Secrets vs Env
USER_DOC.md
 How to start/stop project
 How to access website
 How to access admin panel
 Where credentials are stored
DEV_DOC.md
 Setup from scratch
 Docker commands
 Project structure
 Data persistence explanation



Days 1–2 → 🧠 Understanding & Setup
Install VM + Docker
Learn basics:
Docker images / containers
Volumes / networks
Read the subject carefully

✅ Goal: You understand what you are building

🔹 Days 3–5 → ⚙️ Core Containers
MariaDB setup
WordPress setup (php-fpm)
Connect WordPress ↔ Database

⚠️ This part is the hardest logically

✅ Goal: Backend working without Nginx

🔹 Days 6–7 → 🌐 NGINX + SSL
Install Nginx container
Configure HTTPS (TLS 1.2/1.3)
Reverse proxy to WordPress

✅ Goal: Website works via https://login.42.fr

🔹 Days 8–9 → 🔗 Docker Integration
docker-compose.yml
Volumes (data persistence)
Docker network
Restart policies

✅ Goal: Everything connected and stable

🔹 Days 10–11 → 🔐 Security & Fixes
.env variables
Remove passwords from Dockerfiles
Test crash/restart
Debug errors

✅ Goal: Project respects ALL rules

🔹 Days 12–13 → 📄 Documentation
README.md
USER_DOC.md
DEV_DOC.md

✅ Goal: You can explain EVERYTHING
