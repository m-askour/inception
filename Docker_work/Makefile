# all:
# 	@docker-compose -f ./src/tools/docker-compose.yml up -d

# status : 
# 	@docker ps
# down:
# 	@docker-compose -f ./src/docker-compose.yml down
# clean:
# 	@docker stop $$(docker ps -qa);\
# 	docker rm $$(docker ps -qa);\
# 	docker rmi -f $$(docker images -qa);\
# 	docker volume rm $$(docker volume ls -q);\
#  	docker network rm $$(docker network ls -q)
# re : clean all
all:
	@mkdir -p /home/maskour/data/mariadb
	@mkdir -p /home/maskour/data/wordpress
	@docker compose -f ./src/docker-compose.yml up -d

status:
	@docker ps

down:
	@docker compose -f ./src/docker-compose.yml down

clean:
	@docker compose -f ./src/docker-compose.yml down --volumes --remove-orphans

fclean: clean
	@docker system prune -af

re: fclean all