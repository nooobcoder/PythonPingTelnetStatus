#!/bin/bash

# Ask if the user wants to remove existing cron jobs
read -p "Do you want to remove existing cron jobs? (y/n): " remove_cron_jobs
if [[ "$remove_cron_jobs" == "y" ]]; then
    # Remove existing cron jobs
    crontab -r
fi

# Loop to create new cron jobs
while true; do
    # Get user input for cron pattern, filename, ping count, telnet retry, and log file name
    read -p "Enter cron pattern (e.g. '58 11 * * *'): " cron_pattern
    read -p "Enter filename (e.g. 'pingcheck1'): " filename
    read -p "Enter ping count (default 4): " ping_count
    ping_count=${ping_count:-4}  # Set default value if user input is empty
    read -p "Enter telnet retry (default 4): " telnet_retry
    telnet_retry=${telnet_retry:-4}  # Set default value if user input is empty
    read -p "Enter log file name (default 'logs.log'): " log_file
    log_file=${log_file:-logs.log}  # Set default value if user input is empty

    # Build cron job string
    cron_job_string="$cron_pattern /usr/bin/python /home/biswajit.p@ami.local/OPT/pingTester/Test/Temp/cron_job/python2port.py -f /home/biswajit.p@ami.local/OPT/pingTester/Test/Temp/cron_job/$filename -pc $ping_count -tr $telnet_retry &>/home/biswajit.p@ami.local/OPT/pingTester/Test/Temp/cron_job/cron_output/$log_file"

    # Confirm cron job string with the user
    echo "Your cron job is:"
    echo "$cron_job_string"
    read -p "Is this correct? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        # Add new cron job to crontab
        (crontab -l ; echo "$cron_job_string") | crontab -
        echo "Cron job added successfully."
    fi

    # Ask if the user wants to create another cron job
    read -p "Do you want to create another cron job? (y/n): " create_another
    if [[ "$create_another" == "n" ]]; then
        break
    fi
done
