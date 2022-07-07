#! /bin/bash


#!/bin/sh

echo Hello World

sudo apt update
sudo apt install nginx
sudo service nginx restart


sudo chmod 777 /var/www/html/index.nginx-debian.html

uname -a > /var/www/html/index.nginx-debian.html
df -h >> /var/www/html/index.nginx-debian.html
ps -aux >> /var/www/html/index.nginx-debian.html
