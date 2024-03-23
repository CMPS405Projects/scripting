#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

dnf install -y nginx > /dev/null 2>&1

systemctl enable nginx
systemctl start nginx

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

echo "NGINX service status:"
systemctl status nginx

curl -I http://localhost
