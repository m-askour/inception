#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image


FROM mariadb:11.4
#inctallation

#WORKDIR /the/workdir/path
COPY ./init.sql /docker-entrypoint-initdb.d/
COPY TSL-config /docker-entrypoint-initdb.d/

#RUN command
#CMD [ "executable" ]
EXPOSE 3306