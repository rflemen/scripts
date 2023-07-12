#!/bin/bash
# EXPORT .OVA OF VIRTUALBOX VIRTUAL MACHINE
# Verion 5
# Author: Rob Flemen    Email: rflemen@gmail.com
# REQUIRES: ssmtp package. Need systemctl and ssmtp set for sudoers with no password.

# Global variables
service_name="snipe-it.service"
vm_name="snipeit"
time_stamp=$(date +%m-%d-%Y-%H-%M-%S)
backup_path="/home/mladmin/Backups/snipeit"
log_file_name="/home/mladmin/Backups/logs/${time_stamp}_backup.log"
email_receipient="rflemen@gmail.com"

# Funtion to send email. Args: log file name, email address
function email_log () {
        cat $1 | sudo ssmtp $2
}

# Check if a command executed. Args: result code, log file name, email address
function check_for_success () {
        if [ $1 == 0 ]; then
                echo "SUCCESS! Command successfully executed!" >> $2
        else
                echo "Something went wrong!" >> $2
                email_log $2 $3
                exit 1
        fi
}

# Verify service state. Args: service, log file, email address
function verify_service_state () {
        current_status=$(systemctl status $1 | grep -oe running -oe failed)
        if [[ "$current_status" == "running" ]]; then
                echo "${1} is most definitely UP and ${current_status}!!!" >> $2
        elif  [[ "$current_status" == "failed" ]]; then
                echo "${1} is most definitely DOWN and stopped!!!" >> $2
        else
                echo "Well shoot, something went HORRIBLY wrong!!!" >> $2
                email_log $2 $3
                exit 1
        fi
}

# Header for the logfile
echo "${vm_name} VM Monthly Backup" >> "${log_file_name}"
echo "*************************************" >> "${log_file_name}"
date >> "${log_file_name}"

# Create a folder with a date/time stamp for a name
echo >> "${log_file_name}"
echo "---Creating Date Stamped Directory---" >> "${log_file_name}"
mkdir -p "${backup_path}/${time_stamp}"
check_for_success $? "${log_file_name}" "${email_receipient}"

# Stop the service & verify state
echo >> "${log_file_name}"
echo "---Stopping ${service_name}---" >> "${log_file_name}"
sudo systemctl stop "${service_name}" >> "${log_file_name}" 2>&1
check_for_success $? "${log_file_name}" "${email_receipient}"
verify_service_state "${service_name}" "${log_file_name}" "${email_receipient}"

#Export a copy of the vm to a .ova file
echo >> "${log_file_name}"
echo "---Exporting VM to an .ova File---" >> "${log_file_name}"
VBoxManage export "${vm_name}" -o "${backup_path}/${time_stamp}/${vm_name}.ova" >> "${log_file_name}" 2>&1

# Start the service & verify state
echo >> "${log_file_name}"
echo "---Starting ${service_name}---" >> "${log_file_name}"
sudo systemctl start "${service_name}" >> "${log_file_name}" 2>&1
check_for_success $? "${log_file_name}" "${email_receipient}"
sleep 10 #give service a chance to completely start
verify_service_state "${service_name}" "${log_file_name}" "${email_receipient}"

# Send a copy of the logfile to interested parties
email_log "${log_file_name}" "${email_receipient}"