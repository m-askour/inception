all:
	@docker-compose -f ./src/docker-compose.yml up -d

status:
	@docker ps

down:
	@docker compose -f ./src/docker-compose.yml down

clean:
	@docker compose -f ./src/docker-compose.yml down --volumes --remove-orphans

fclean: clean
	@docker system prune -af

re: fclean all
