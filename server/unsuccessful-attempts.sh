#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

dnf install -y cronie > /dev/null
systemctl enable crond
systemctl start crond

mkdir -p "/home/server/log"

LOG="/home/server/log/unsuccessful_attempts.log"


consolidate_logs() {
    echo "Consolidating logs."
    rm -f "$LOG"
    for user in $(ls /home); do
        if [ -f "/home/$user/invalid_attempts.log" ]; then
            cat "/home/$user/invalid_attempts.log" >> "$LOG"
        fi
    done
}

cleanup_logs() {
    echo "Cleaning up logs older than 7 days."
    if [ $(find "$LOG" -type f -mtime +7) ];then
        rm -f "$LOG"
    else
        echo "No logs to clean up."
    fi
}

schedule_cleanup() {
    if grep -q "unsuccessful-attempts.sh" < $(crontab -l); then
        echo "Cron job already scheduled."
        exit 0
    fi
    echo "Scheduling cron job."
    (crontab -l ; echo "0 0 * * * /home/server/scripting/server/unsuccessful-attempts.sh") | crontab -
}

consolidate_logs

cleanup_logs

schedule_cleanup