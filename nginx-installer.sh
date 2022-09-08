#!/usr/bin/env bash
# Installs nginx, sets it up to listen on port 80 and creates a landing page

# Checks if nginx is already installed
if [ -x "$(command -v nginx)" ]; then
    echo "Nginx already installed. commencing cleanup..."
    sleep 1
    sudo systemctl stop nginx
    sudo apt-get remove nginx nginx-common -y
    sudo apt-get purge nginx nginx-common -y
    sudo apt-get autoremove -y
    sudo rm /var/www/html/softserve
    sudo rm /var/www/html/index.html
    echo "Clean up complete commencing nginx installation..."
    sleep 3
fi

#updates apt repo
sudo apt-get update -y
sudo apt-get upgrade -y

# Installs nginx
sudo apt-get install nginx -y

# Creates the directory
sudo mkdir -p /var/www/html/softserve

# Enables write permissions to other
sudo chmod -R o+w /var/www/html

# Unlinks the default file
sudo unlink /etc/nginx/sites-enabled/default

# Enable write permissions to other
sudo chmod -R o+w /etc/nginx/conf.d/

# Creates the config file
sudo echo "server {
    listen 80 default_server;
    index index.html;
    root /var/www/html/;
    }" > /etc/nginx/conf.d/softserve.conf


# Starts the server
sudo service nginx start

# Creates the index file
sudo echo "Hello World $(hostname)" > /var/www/html/index.html;