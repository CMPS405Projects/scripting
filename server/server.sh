#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Setting up server..."
echo

echo "General configuration..."
./config-general.sh

echo "Setting up SSH..."
./config-sshd.sh

echo;echo

echo "Setting up NGINX Webserver..."
./config-nginx.sh

echo;echo

echo "Configuring Quad9 DNS..."
./config-dns.sh

echo;echo

echo "Setting up Mobile Shell..."
./config-mosh.sh

echo;echo

echo "Creating clients and configuring client's website from clients.csv..."
while IFS=, read -r username fullname
do
    ./create-client.sh "$username" "$fullname"
    ./config-site.sh "$username"
done < ../clients.csv
