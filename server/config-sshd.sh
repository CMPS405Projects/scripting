#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Installing OpenSSH server..."
dnf install -y openssh-server > /dev/null

echo "Configuring OpenSSH server..."
systemctl enable sshd
systemctl start sshd

# check if the line exists in the file
grep -q "AllowGroups clients" /etc/ssh/sshd_config || echo "AllowGroups clients" >> /etc/ssh/sshd_config

systemctl restart sshd

echo -n "Adding firewall rules: "
firewall-cmd --permanent --zone=public --add-service=ssh
echo -n "Relaoding firewall: "
firewall-cmd --reload

echo "SSH service status:"
systemctl status sshd
