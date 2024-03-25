#!/bin/bash

clients_group() {
	if getent group clients > /dev/null; then
		echo clients group exists
		if groups $USER | grep -q "clients"; then
			echo $USER is part of clients group
			echo Proceeding with script execution...
		else
			echo $USER is not part of clients group
			sudo usermod -aG clients $USER
		fi
	else
		sudo addgroup clients
		sudo usermod -aG clients $USER
	fi
}

connect_to_server() {
	# read -p "Enter Username: " username
	ssh $USER@$SERVER_IP 2> ./err
	code=$?
	if cat ./err | grep -q "No route to host"; then
        echo "Connection Failed. Server may be down." >&2
        exit 1
	fi

}

log_invalid_attempt() {
	# Print p timestamp t and user u
	echo $(date +"%Y-%m-%d %H:%M:%S") - $USER: $1 >> ~/invalid_attempts.log
}

handle_excessive_invalid_attempts() {
	echo "Unauthorized user!"
	rsync ~/invalid_attempts.log $USER@$SERVER_IP:/home/$USER
	gnome-session-quit --no-prompt
}

main() {
	if [ "root" != $USER ]; then
		clients_group
		connect_to_server
		if [ $code -eq 255 ]; then
			log_invalid_attempt "SSH Login failed. Invalid password"
			handle_excessive_invalid_attempts
		fi
	else
		echo Please run script using normal user privileges
		exit 1
	fi
}

if [ $# -ne 1 ]; then
	echo "Please provide server IP" >&2
	exit 1
else
	SERVER_IP=$1
	main
fi
