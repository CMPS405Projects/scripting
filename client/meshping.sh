#!/bin/bash

log() {
	msg="$(date +"%Y-%m-%d %H:%M:%S") $1"
	echo $msg
	echo $msg >> ~/network.log
}

echo
for ip in $@; do
	ping -c 2 -W 4 $ip
	if [ $? -ne 0 ]; then
		log "Unable to ping $ip. Trying traceroute..."
		traceroute $ip
		if [ $? -ne 0 ]; then
			log "Unable to traceroute $ip. Rebooting target machine..."
			ssh reboot@$ip "echo reboot | sudo -S reboot"
		fi
	fi
	log "Connectivity with $ip is ok"
	echo
done