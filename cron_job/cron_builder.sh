#!/bin/bash


DEFAULT_PING_COUNT=4
DEFAULT_TELNET_RETRY=4
DEFAULT_LOG_FILENAME="logs.log"

# Function to generate the cron pattern
generate_cron_pattern() {
    echo "Please specify the following values to generate the cron pattern:"
    echo "1. Minute (0-59)"
    read -p "   (default: *): " minute
    minute=${minute:-*}
    echo "2. Hour (0-23)"
    read -p "   (default: *): " hour
    hour=${hour:-*}
    echo "3. Day of the month (1-31)"
    read -p "   (default: *): " day_of_month
    day_of_month=${day_of_month:-*}
    echo "4. Month (1-12)"
    read -p "   (default: *): " month
    month=${month:-*}
    echo "5. Day of the week (0-6, Sunday is 0)"
    read -p "   (default: *): " day_of_week
    day_of_week=${day_of_week:-*}
    cron_pattern="$minute $hour $day_of_month $month $day_of_week"
    echo "$cron_pattern"
}

# function to increment log filename
increment_log_filename() {
  log_filename=$1

  if [[ $log_filename == $DEFAULT_LOG_FILENAME ]]; then
    new_log_filename="logs2.log"
  else
    log_number=$(echo "$log_filename" | sed 's/[^0-9]*//g')
    new_log_number=$((log_number+1))
    new_log_filename="logs$new_log_number.log"
  fi

  echo "$new_log_filename"
}

# function to generate cron job string
generate_cron_job_string() {
  cron_pattern=$1
  ping_check_filename=$2
  ping_count=$3
  telnet_retry=$4
  log_filename=$5

  cron_job_string="$cron_pattern /usr/bin/python /home/biswajit.p@ami.local/OPT/pingTester/Test/Temp/cron_job/python2port.py -f /home/biswajit.p@ami.local/OPT/pingTester/Test/Temp/cron_job/$ping_check_filename -pc $ping_count -tr $telnet_retry &>/home/biswajit.p@ami.local/OPT/pingTester/Test/Temp/cron_job/cron_output/$log_filename"

  echo "$cron_job_string"
}

# Ask if the user wants to remove existing cron jobs
read -p "Do you want to remove existing cron jobs? (y/n): " remove_cron_jobs
if [[ "$remove_cron_jobs" == "y" ]]; then
    # Remove existing cron jobs
    crontab -r
fi

# Loop to create new cron jobs
while true; do
    # Get user input for cron pattern, filename, ping count, telnet retry, and log file name
    # Generate the cron pattern
    read -p "Do you want to generate the cron pattern? (y/n): " generate_cron_pattern
    if [[ "$generate_cron_pattern" == "y" ]]; then
        echo "Please specify the following values to generate the cron pattern:"
        echo "1. Minute (0-59)"
        read -p "   (default: *): " minute
        minute=${minute:-*}
        echo "2. Hour (0-23)"
        read -p "   (default: *): " hour
        hour=${hour:-*}
        echo "3. Day of the month (1-31)"
        read -p "   (default: *): " day_of_month
        day_of_month=${day_of_month:-*}
        echo "4. Month (1-12)"
        read -p "   (default: *): " month
        month=${month:-*}
        echo "5. Day of the week (0-6, Sunday is 0)"
        read -p "   (default: *): " day_of_week
        day_of_week=${day_of_week:-*}
        cron_pattern="$minute $hour $day_of_month $month $day_of_week"
    else
        read -p "Enter the cron pattern (e.g. '58 11 * * *'): " cron_pattern
    fi

    read -p "Enter ping check filename: " ping_check_filename
    read -p "Enter ping count (default $DEFAULT_PING_COUNT): " ping_count_input
    ping_count=${ping_count_input:-$DEFAULT_PING_COUNT}
    read -p "Enter telnet retry (default $DEFAULT_TELNET_RETRY): " telnet_retry_input
    telnet_retry=${telnet_retry_input:-$DEFAULT_TELNET_RETRY}
    read -p "Enter log filename (default $DEFAULT_LOG_FILENAME): " log_filename
    log_filename=${log_filename:-$DEFAULT_LOG_FILENAME}

    # Build cron job string
    cron_job_string=$(generate_cron_job_string "$cron_pattern" "$ping_check_filename" "$ping_count" "$telnet_retry" "$log_filename")
    echo "Cron job string: $cron_job_string"

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
