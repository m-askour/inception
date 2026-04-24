#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image
FROM wordpress:latest


#WORKDIR /the/workdir/path
RUN docker-php-ext-install mysqli gb

#COPY source dest

COPY wp-config.php /usr/src/wordpress/wp-config.php

#set correct permission "this is option"
RUN chow www-data:www-data /usr/src/wordpress/wp-config.php
#CMD [ "executable" ]


#EXPOSE port