#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

DNS_SERVER_1="9.9.9.9"
DNS_SERVER_2="149.112.112.112"

echo "Removing existing DNS servers..."
sed -i '/nameserver/d' /etc/resolv.conf

echo "Adding Quad9 DNS servers..."
echo "nameserver $DNS_SERVER_1" | tee -a /etc/resolv.conf
echo "nameserver $DNS_SERVER_2" | tee -a /etc/resolv.conf

echo "Quad9 DNS servers configured successfully."
