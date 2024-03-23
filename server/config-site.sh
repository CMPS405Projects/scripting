#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

username="$1"

if [ -z "$username" ]; then
    echo "Error: Username argument is missing."
    exit 1
fi

user_home="/home/$username"
if [ ! -d "$user_home" ]; then
    echo "Error: Home directory for user $username does not exist."
    exit 1
fi

site_directory="$user_home/site"
nginx_html="/usr/share/nginx/html/$username"

if [ ! -d "$site_directory" ]; then
    mkdir -p "$site_directory"
fi

ln -sfn "$site_directory" "$nginx_html"

chown -R nginx:nginx "$site_directory"
chmod -R 755 "$site_directory"

chmod o+rx "$user_home"

echo "Website directory for user $username configured successfully."
