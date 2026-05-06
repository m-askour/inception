#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image
FROM debian:latest


#WORKDIR /the/workdir/path
#COPY source dest
COPY instll_wordPress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/instll_wordPress.sh
#
RUN docker-php-ext-install mysqli gd
RUN apt-get update && apt-get install -y mariadb-client && apt-get clean && apt


#CMD [ "executable" ]




EXPOSE 9000