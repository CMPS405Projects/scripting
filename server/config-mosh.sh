#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Installing Mobile Shell (Mosh)..."
dnf install mosh -y > dev/null

echo "Configuring Mosh..."
tee /etc/firewalld/services/mosh.xml > /dev/null <<EOF
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>mosh</short>
  <description>Mosh service</description>
  <port protocol="udp" port="60000"/>
  <port protocol="udp" port="60001"/>
  <port protocol="udp" port="60002"/>
</service>
EOF

echo -n "Adding firewall rules: "
firewall-cmd --permanent --add-service=mosh
echo -n "Reloading firewall: "
firewall-cmd --reload

echo "Mosh configured successfully."
