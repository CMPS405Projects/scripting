#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

dnf install -y nginx > /dev/null

echo "Enabling NGINX service: "
systemctl enable nginx
systemctl start nginx

echo -n "Adding firewall rules: "
firewall-cmd --permanent --zone=public --add-service=http
echo -n "Reloading firewall: "
firewall-cmd --reload

echo "NGINX service status:"
systemctl status nginx



curl -I http://localhost
