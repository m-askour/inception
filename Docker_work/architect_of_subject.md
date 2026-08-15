├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── tools/
        │       └── TSL-config.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb.conf
        │   └── tools/
        │       └── database.sh
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── install_wordPress.sh