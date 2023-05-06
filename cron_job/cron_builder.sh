#!/bin/bash

DEFAULT_PING_COUNT=4
DEFAULT_TELNET_RETRY=4
DEFAULT_LOG_FILENAME="logs.log"

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

# prompt user to remove existing cron jobs
read -p "Do you want to remove existing cron jobs? (y/n): " remove_existing

if [[ $remove_existing == "y" ]]; then
  # remove existing cron jobs
  crontab -r
fi

while true; do
  # prompt user for input
  read -p "Enter cron pattern (e.g. 58 11 * * *): " cron_pattern
  read -p "Enter ping check filename: " ping_check_filename
  read -p "Enter ping count (default $DEFAULT_PING_COUNT): " ping_count_input
  ping_count=${ping_count_input:-$DEFAULT_PING_COUNT}
  read -p "Enter telnet retry (default $DEFAULT_TELNET_RETRY): " telnet_retry_input
  telnet_retry=${telnet_retry_input:-$DEFAULT_TELNET_RETRY}
  read -p "Enter log filename (default $DEFAULT_LOG_FILENAME): " log_filename
  log_filename=${log_filename:-$DEFAULT_LOG_FILENAME}

  # generate cron job string and output to user
  cron_job_string=$(generate_cron_job_string "$cron_pattern" "$ping_check_filename" "$ping_count" "$telnet_retry" "$log_filename")
  echo "Cron job string: $cron_job_string"

  # prompt user to build another cron job
  read -p "Do you want to build another cron job? (y/n): " build_another

  # exit loop if user does not want to build another cron job
  if [[ $build_another == "n" ]]; then
    break
  fi

  # increment log filename for next iteration
  DEFAULT_LOG_FILENAME=$(increment_log_filename "$log_filename")
done

# set cron jobs
echo "$cron_job_string" | crontab -
