#!/bin/bash

# Script: Disk Space Monitor with Email Alerts
# Author: Bogdan Turcanu
# Description: Monitors disk usage and sends email alerts if usage exceeds set thresholds.

# Usage Instructions:
# Replace your@email.com with the actual email address where alerts should be sent.
# Set ALERT_THRESHOLD to the desired percentage (e.g., 90 for 90%).
# Modify MONITOR_PATHS to include the paths you want to monitor for disk usage.
# Ensure the mail utility is correctly configured on your system for sending emails.

# Notes:
# The script uses the df command to get disk usage information and awk for parsing this data.
# The mail command is used for sending email alerts. Ensure that your system is configured to send emails (e.g., setting up sendmail or postfix).
# You might need to modify the mail command options depending on your system's configuration or if using a different mail utility.
# For continuous monitoring, consider setting up a cron job to run this script at regular intervals, like every hour or once a day.

# Configuration
ALERT_EMAIL="your@email.com"
ALERT_THRESHOLD=90 # Disk usage percent threshold for alerting
MONITOR_PATHS=("/" "/home" "/var") # Paths to monitor, add as needed

# Function to check disk space and send email alert
check_disk_space() {
    for path in "${MONITOR_PATHS[@]}"; do
        local usage=$(df -h "${path}" | awk 'NR==2 {print $(NF-1)}' | sed 's/%//g')

        if [ "${usage}" -ge "${ALERT_THRESHOLD}" ]; then
            echo "Disk space alert for ${path}: ${usage}% used" | mail -s "Disk Space Alert on $(hostname)" "${ALERT_EMAIL}"
        fi
    done
}

# Main Execution
check_disk_space
