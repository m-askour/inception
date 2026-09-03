all: up
 
up:
	@mkdir -p /home/maskour/data/mariadb /home/maskour/data/wordpress
	@docker compose -f ./src/docker-compose.yml up -d --build
 
down:
	@docker compose -f ./src/docker-compose.yml down
 
stop:
	@docker compose -f ./src/docker-compose.yml stop
 
start:
	@docker compose -f ./src/docker-compose.yml start
 
status:
	@docker ps
 
clean: down
	@docker system prune -f
 
fclean: clean
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	@docker rmi -f $$(docker images -qa) 2>/dev/null || true
	@sudo rm -rf /home/maskour/data/mariadb /home/maskour/data/wordpress
 
re: fclean all