#!/bin/bash

configure_ssh_server() {
    systemctl enable sshd
    systemctl start sshd
    
    # check if the line exists in the file
    grep -q "AllowGroups clients" /etc/ssh/sshd_config || echo "AllowGroups clients" >> /etc/ssh/sshd_config
    
    systemctl restart sshd
}

configure_firewall() {
    firewall-cmd --permanent --zone=public --add-service=ssh
    firewall-cmd --reload
}

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

echo "Installing OpenSSH server..."
dnf install -y openssh-server > /dev/null

echo "Configuring OpenSSH server..."
configure_ssh_server

echo "Adding firewall rules..."
configure_firewall

echo "SSH service status:"
systemctl status sshd
