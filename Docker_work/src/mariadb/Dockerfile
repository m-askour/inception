#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image


###latest mean it's the last virsion image of this image
FROM debian:latest

#RUN command

#install the mariadb server


#WORKDIR /the/workdir/path
COPY init.sql /docker-entrypoint-initdb.d/
COPY mariadb.conf /etc/mysql/mariadb.conf.d/
COPY database_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/database_setup.sh
RUN apt-get update && apt-get install -y mariadb-server mariadb-client && apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*



#CMD [ "executable" ]
EXPOSE 3306