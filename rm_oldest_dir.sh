#!/bin/bash
# COUNT DIRECTORIES IN A DIRECTORY AND DELETE OLDEST
# Author: Rob Flemen

current_dir="/home/Public/Backups/fdss"
log_file_name="/home/rflemen/logs/del_old_backups.log"
email_receipient="test@gmail.com"
NOW=$(date +"%m_%d_%Y")

# Set maximum directories for current directory
max_dirs=3

# Determine the number of directories in current directory
cd "${current_dir}"
num_of_dirs=$(ls -d */ | wc -l)

# Determine which of the directories is the oldest
oldest_dir=$(ls -dtr */ | head -n 1)

function print_stats () {
        echo "[-]      Max dirs: ${max_dirs}" >> "${log_file_name}"
        echo "[-]      Number of dirs: ${num_of_dirs}" >> "${log_file_name}"
        echo "[-]      Oldest dir: ${oldest_dir}" >> "${log_file_name}"
        echo >> "${log_file_name}"
}

# Header for the logfile
 echo "[+] Running Backup Retention Cleanup Script" >> "${log_file_name}"
        echo "[-]      Current dir: ${current_dir}" >> "${log_file_name}"
echo >> "${log_file_name}"

# Check to see if we over limit and if needed delete oldest directory or directories

while [ $num_of_dirs -gt $max_dirs ]; do
        echo "[+] ${num_of_dirs} directories, over the limit of ${max_dirs} - deleting ${oldest_dir}" >> "${log_file_name}"
        rm -rf ${oldest_dir}
        if [ $? == 0 ]; then
                echo "[-]      Successfully deleted ${oldest_dir}" >> "${log_file_name}"
        else
                echo "[-]      Something went wrong" >> "${log_file_name}"
        fi
        ((num_of_dirs--))
        oldest_dir=$(ls -dtr */ | head -n 1)
        print_stats
done

# Send a copy of the logfile to interested parties
cat ${log_file_name}  | sudo ssmtp "${email_receipient}"
