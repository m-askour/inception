#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image


###latest mean it's the last virsion image of this image
FROM debian:buster

#RUN command

#install the mariadb server


#WORKDIR /the/workdir/path
RUN apt-get update -y && apt-get install mariadb-server -y
COPY init.sql /docker-entrypoint-initdb.d/
COPY mariadb.conf /etc/mysql/mariadb.conf.d/
COPY database_setup.sh /usr/local/bin/




#CMD [ "executable" ]



EXPOSE 3306

CMD ["mysqld"]