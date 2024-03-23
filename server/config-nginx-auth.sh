#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Installing Apache Utils..."
dnf install -y apache2-utils > /dev/null 2>&1

echo "Creating .htpasswd file..."
while IFS=, read -r username fullname
do
    htpasswd -c /etc/nginx/.htpasswd "$username"
done < ../clients.csv

cat << 'EOF' > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        auth_basic "Needs Authentication";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF

# Reload the NGINX service
systemctl restart nginx

echo "NGINX service status:"
systemctl status nginx

# Test the configuration
curl -I http://localhost