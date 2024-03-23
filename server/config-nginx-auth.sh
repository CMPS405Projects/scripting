#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Installing Apache Utils..."
dnf install -y httpd-tools > /dev/null

echo "Creating .htpasswd file..."
while IFS=, read -r username fullname
do
    htpasswd -c /etc/nginx/.htpasswd "$username" "$username"
done < ../clients.csv

cat > /etc/nginx/conf.d/default.conf <<EOF
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

cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>CMPS405 Lab</title>
</head>
<body style="display:grid;place-items:center;">
    <h1 style="font-size:5rem;">Welcome to Operating Systems Lab</h1>
</body>
</html>
EOF

systemctl restart nginx

echo "NGINX service status:"
systemctl status nginx

curl -I http://localhost