NAME_USER=maskour
DATA_PATH=./home/${NAME_USER}/data

all:
	@mkdir -p ${DATA_PATH}/mariadb ${DATA_PATH}/wordpress
	@docker compose -f ./src/docker-compose.yml up -d --build

status:
	@docker compose -f ./src/docker-compose.yml ps

down:
	@docker compose -f ./src/docker-compose.yml down

clean:
	@docker compose -f ./src/docker-compose.yml down --volumes --remove-orphans

fclean: clean
	@docker system prune -af

re: fclean all
