#!/bin/bash
# EXPORT .OVA OF VIRTUALBOX VIRTUAL MACHINE v3
# Author: Rob Flemen    Email: rflemen@gmail.com
# Script to export a backup .ova file of the vm running in VirtualBox
# REQUIRES: ssmtp package & systemctl and ssmtp via sudo w/ no password

# Declare global variables
service_name="fdss-vm.service"
vm_name="fdss"
time_stamp=$(date +%m-%d-%Y-%H-%M-%S)
backuppath="/home/rflemen/Backups/fdss"
log_file_name="/home/rflemen/Backups/logs/${time_stamp}_backup.log"
email_receipient="rflemen@gmail.com"

# Function to send the log via email
function email_log () {
        cat $1 | sudo ssmtp $2
}

# Function check to see if a command executed successfully.
function check_for_success () {
        if [ $1 == 0 ]; then
                echo "SUCCESS! Command executed!" >> "${log_file_name}"
        else
                echo "Something went wrong!" >> "${log_file_name}"
                email_log $2 $3
                exit 1
        fi
        }

# Header for the logfile
echo "${vm_name} VM Monthly Backup" >> "${log_file_name}"
echo "*************************************" >> "${log_file_name}"
date  >> "${log_file_name}"


# Create a folder with a date/time stamp for a name
echo >> "${log_file_name}"
echo "---Creating Date Stamped Directory---" >> "${log_file_name}"
mkdir -p "${backuppath}/${time_stamp}"
check_for_success $? "${log_file_name}" "${email_receipient}"

# Stop the service
echo >> "${log_file_name}"
echo "---Stopping ${service_name}---" >> "${log_file_name}"
sudo systemctl stop "${service_name}" >> "${log_file_name}" 2>&1
check_for_success $? "${log_file_name}" "${email_receipient}"
current_status=$(systemctl status "${service_name}" | grep -o failed)
if [ "$current_status" == "failed" ]; then
        echo "Hooray! ${service_name} is most definitely down!!!" >> "${log_file_name}"
else
        echo "Well shoot, something really went HORRIBLY wrong!" >> "${log_file_name}"
        email_log "${log_file_name}" "${email_receipient}"
        exit 1
fi

# Export a copy of the vm to a .ova file
echo >> "${log_file_name}"
echo "---Exporting VM to an .ova File---" >> "${log_file_name}"
VBoxManage export "${vm_name}" -o "${backuppath}/${time_stamp}/${vm_name}.ova" >> "${log_file_name}" 2>&1

# Start the service
echo >> "${log_file_name}"
echo "---Starting ${service_name}---" >> "${log_file_name}"
sleep 20
sudo systemctl start "${service_name}" >> "${log_file_name}" 2>&1
check_for_success $? "${log_file_name}" "${email_receipient}"

# Check the status of the service and append to log
echo >> "${log_file_name}"
sleep 10
echo "---Checking status of ${service_name}---" >> "${log_file_name}"
current_status=$(systemctl status "${service_name}" | grep -o running)
if [ "$current_status" == "running" ]; then
        echo "Hooray! ${service_name} is most definitely UP and ${current_status}!!!" >> "${log_file_name}"
else
        echo "Well shoot, something really went HORRIBLY wrong!" >> "${log_file_name}"
fi

# Send a copy of the logfile to interested parties
email_log "${log_file_name}" "${email_receipient}"