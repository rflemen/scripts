#!/bin/bash
# COUNT DIRECTORIES IN A DIRECTORY AND DELETE OLDEST
# Author: Rob Flemen    Email: <insert email address>
# Script to count the number of directories in current directory
# and delete the oldest on if it exceeds the limit set.

current_dir="/home/mladmin/Backups/snipeit"
date_stamp=$(date +%m-%d-%Y)
log_file_name="/home/mladmin/Backups/logs/${date_stamp}_clean_dir.log"
email_receipient="<insert email address>"
max_dirs=3

# Determine the number of directories in current directory
cd "${current_dir}"
num_of_dirs=$(ls -d */ | wc -l)

# Determine which of the directories is the oldest
oldest_dir=$(ls -dtr */ | head -n 1)

# Header for the log file
echo "Backup Retention Correction Script" >> "${log_file_name}"
echo "*************************************" >> "${log_file_name}"
date >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Current dir: ${current_dir}" >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Max num of dirs: ${max_dirs}" >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Current num of dirs: ${num_of_dirs}" >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Oldest dir: ${oldest_dir}" >> "${log_file_name}"
echo >> "${log_file_name}"

#Check to see if we over limit and delete oldest directory, if needed
if [ $num_of_dirs -gt $max_dirs ]; then
        echo "We are over the limit so we're deleting ${oldest_dir}" >> "${log_file_name}"
        sleep 5
        rm -rf ${oldest_dir}
        if [ $? == 0 ]; then
                echo "SUCCESS! ${oldest_dir} has been deleted!" >> "${log_file_name}"
                echo >> "${log_file_name}"
        else
                echo "Something went wrong!" >> "${log_file_name}"
                echo >> "${log_file_name}"
        fi
else
        echo "There aren't enough directories so there is nothing to do!!!" >> "${log_file_name}"
fi

# Send a copy of the logfile to interested parties
cat "${log_file_name}"  | sudo ssmtp "${email_receipient}"
