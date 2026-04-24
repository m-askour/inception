##this able to bundle my one static web content or custom configuration 
#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image

FROM nginx;lstes
#WORKDIR /the/workdir/path
#this is for the nginx configue
COPY ./nginx.conf /etc/nginx/nginx.conf



#this is for content 
COPY ../wordpress /usr/share/nginx/html


##Configure TLS certificate



#openssl req -x509


#Configure NGINX reverse proxy



#RUN command
#CMD [ "executable" ]
EXPOSE 80