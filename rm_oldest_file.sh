#!/bin/bash
# COUNT FILES IN A DIRECTORY AND DELETE OLDEST
# Verion 1
# Author: Rob Flemen
# Email: rob@marleylilly.com

# Script to count the number of files in current directory
# and delete the oldest one if it exceeds the max set.

current_dir="/Backups"
date_stamp=$(date +%m-%d-%Y)
time_stamp=$(date +%H_%M_%S)
log_file_name="/Backups/logs/del_old_backups.log"
max_files=30
email_recipient="rob@marleylilly.com"

# Determine the number of directories in current directory
cd "${current_dir}"
num_of_files=$(find . -maxdepth 1 -type f | wc -l)

# Determine which of the directories is the oldest
oldest_file=$(find . -maxdepth 1 -type f | sort | head -n 1)

# Header for the logfile
echo "Snipe-IT Backup Retention Cleanup Script" >> "${log_file_name}"
echo "**************************************" >> "${log_file_name}"
date >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Current dir: ${current_dir}" >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Max # of files: ${max_files}" >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Current # of files: ${num_of_files}" >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Oldest file: ${oldest_file}" >> "${log_file_name}"
echo >> "${log_file_name}"

# Check to see if we over limit and delete oldest file, if needed
if [ $num_of_files -gt $max_files ]; then
        echo "We are over the limit so we're deleting ${oldest_file}" >> "${log_file_name}"
        sleep 5
        rm ${oldest_file}
        if [ $? == 0 ]; then
                echo "SUCCESS! ${oldest_file} has been deleted!" >> "${log_file_name}"
                echo >> "${log_file_name}"
        else
                echo "Something went wrong!" >> "${log_file_name}"
                echo >> "${log_file_name}"
        fi
else
        echo "There aren't enough files so there is nothing to do!!!" >> "${log_file_name}"
fi

# Send a copy of the logfile to interested parties
cat "${log_file_name}"  | sudo ssmtp "${email_recipient}"