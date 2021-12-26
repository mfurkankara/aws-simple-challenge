#!/bin/sh
sudo apt update -y

sudo apt install nginx -y 
echo "server {
    listen 80;
    server_name _;
    location /myflaskapp {
        proxy_pass http://localhost:5000/;
        }
    }" >> server
sudo rm /etc/nginx-sites-enabled/default
sudo nginx -t
sudo nginx -s reload

sudo mv server /etc/nginx/sites-enabled/
sudo chown root:root /etc/nginx/sites-enabled/server


sudo apt install -y docker.io
sudo usermod -a -G docker ubuntu
sudo docker swarm init

sudo docker service create --name flask --publish published=5000,target=5000 mfurkankara/flask:1