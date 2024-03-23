#!/bin/bash

username="techuser"
group="admins"
path="/home/client1/main.sh"

verify() {
	# If techuser exits delete it
	if id $username &> /dev/null; then
		sudo deluser $username
		sudo rm -r /home/$username
	fi

	# Create techuser
	sudo useradd -m $username
	echo "$username:techuser" | sudo chpasswd &> /dev/null
	$ Run main.sh under techuser
	sudo -u $username $path

	# If admins group exists delete it
	if getent group $group &> /dev/null; then
		sudo delgroup $group
	fi
	# If admins group in sudoers delete it
	if sudo grep -qE "^%$group" "/etc/sudoers"; then
		sudo sed -i "/^%$group/d" "/etc/sudoers"
	fi

	# Create admins group
	sudo groupadd admins
	# Add admins group to sudoers
	echo "%admins ALL=(ALL) ALL" | sudo tee -a /etc/sudoers
	# Add techuser to admins group
	sudo usermod -aG $group $username
	# Run main.sh udner techuser
	sudo -u $username $path
}

verify