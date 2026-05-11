##this able to bundle my one static web content or custom configuration 
#this file us to ordered the automate the creat of the doker image as a list of the commands 
#each iinstruction in the file creat a new layer in the image

# FROM debian:buster

# # 1. Install dependencies FIRST
# RUN apt-get update && apt-get install -y \
#     nginx \
#     openssl \
#  && apt-get clean && rm -rf /var/lib/apt/lists/*

# # 2. Copy nginx config

# # 3. Copy TLS script
# COPY TLS-config.sh /usr/local/bin/TLS-config.sh
# COPY nginx.conf /etc/nginx/nginx.conf
# RUN chmod +x /usr/local/bin/TLS-config.sh

# # 4. Give execute permission

# # 5. Expose HTTPS port
# EXPOSE 443

# # 6. Start script (entrypoint behavior)
# CMD ["/usr/local/bin/TLS-config.sh"]
FROM debian:buster


RUN apt -y update && apt install -y nginx && apt install openssl -y




# COPY ./conf/default /etc/nginx/sites-available/

COPY ./tools/script.sh /


CMD [ "/script.sh" ]