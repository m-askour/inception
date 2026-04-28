#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image


###latest mean it's the last virsion image of this image
FROM mariadb:latest 

#RUN command
#install the mariadb server
RUN apt-get update -y && apt-get install -y mysql-server 


#WORKDIR /the/workdir/path
COPY ./init.sql /docker-entrypoint-initdb.d/
COPY mariadb.conf /etc/mysql/mariadb.conf.d/

#CMD [ "executable" ]
EXPOSE 3306