#!/bin/bash
# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done
# install nginx
echo install nginx
apt-get update
apt-get -y install nginx
# make sure nginx is started
echo start nginx
service nginx start
echo  nginx startedddDDDDD!!!
sudo chmod 660 /var/www/html/index.nginx-debian.html
uname -a >> /var/www/html/index.nginx-debian.html


# install docker
echo install docker
sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo docker run hello-world

echo docker installed
