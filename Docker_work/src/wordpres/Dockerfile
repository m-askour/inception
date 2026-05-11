#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image
FROM debian:buster

#install php and php-fdm
RUN apt-get update && apt-get install -y php php-fpm
#WORKDIR /the/workdir/path
#COPY source dest
COPY instll_wordPress.sh /usr/local/bin/

#CMD [ "executable" ]

CMD ["php-fpm"]


EXPOSE 9000