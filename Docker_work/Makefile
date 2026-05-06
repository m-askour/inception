all:
	@docker-compose -f ./src/docker-compose.yml up -d

status : 
	@docker ps
down:
	@docker-compose -f ./src/docker-compose.yml down
clean:
	@docker stop $$(docker ps -qa);\
	docker rm $$(docker ps -qa);\
	docker rmi -f $$(docker images -qa);\
	docker volume rm $$(docker volume ls -q);\
	docker network rm $$(docker network ls -q)