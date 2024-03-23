#!/bin/bash

create_user() {
    local username=$1
    local full_name=$2
    local home_dir="/home/$username"
    
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
        exit 1
    fi
    
    useradd -m -c "$full_name" -s /bin/bash -d "$home_dir" "$username"
    
    # local password=$(pwgen -s 12)
    local password=$username
    
    echo -e "$password\n$password" | passwd "$username"
    
    if ! getent group clients > /dev/null 2>&1; then
        groupadd clients
    fi
    usermod -aG clients "$username"
    
    if ! grep -q "^$username" /etc/sudoers; then
        echo "$username ALL=(ALL:ALL) ALL" >> /etc/sudoers
    fi
    
    echo "User $username created with password: $password"
}

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <full name>"
    exit 1
fi

# dnf install -y pwgen > /dev/null 2>&1

create_user "$1" "$2"
