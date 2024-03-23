#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Setting up needed things for the server..."
echo

echo "Updating the system..."
dnf update -y

echo;echo

echo "Do you want to install MATE Desktop? (y/n)"
read answer
if [ "$answer" == "y" ] || [ "$answer" == "Y" ] ;then
    echo "Installing MATE Desktop..."
    dnf groupinstall -y "MATE Desktop"
    systemctl set-default graphical.target
else
    echo "MATE Desktop will not be installed."
fi

echo;echo

echo "Setting up server..."
chmod +x ./*.sh
echo

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

echo;echo

echo "Setting up NGINX authentication..."
./config-nginx-auth.sh

echo;echo

echo "Setting up consolidating logs..."
./unsuccessful-attempts.sh &

echo;echo

echo "Do you want to reboot? (y/n)"
read answer
if [ "$answer" == "y" ] || [ "$answer" == "Y" ] ;then
    reboot
else
    echo "Please reboot later."
    exit 0
fi
