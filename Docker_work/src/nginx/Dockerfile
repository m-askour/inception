##this able to bundle my one static web content or custom configuration 
#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image

FROM debian:latest
#WORKDIR /the/workdir/path
# COPY ../wordpress /usr/share/nginx/html
COPY nginx.conf /usr/src/nginx.conf -d/

COPY TLS-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/TLS-config.sh
RUN apt-get update && apt-get install -y nginx openssl && apt-get clean && apt





##Configure TLS certificate



#openssl req -x509


#Configure NGINX reverse proxy



#RUN command
#CMD [ "executable" ]
EXPOSE 80