#!/bin/sh

#use this script to run ther files and use the code inside of the configue and the dockerfile use to run it automatic li 
#install the ssl certificate script
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout myndfun.key -out myndfin.crt
#openssl : use to  encryption , certifacates keys
#-req :certificat requarment (use to creat the csr or directly creat the certificat like what i do )("-x509"=>gnerat the self-segned certificat directly)
#-noods : No DES (no encryption) beacaus docker conainer must start automaticlly no interactive password
#newkey : this to creat the new key and rsa -> encryption algorithm and the 2048-> this is the key size
#keyout myndfun.key this is the output file for the privetkey "secretfile
#out mynfin.crt: this is the output file certificat "public file"

