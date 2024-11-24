#!/bin/bash
# EXPORT .OVA OF VIRTUALBOX VIRTUAL MACHINE
# Author: Rob Flemen

# Script to export a backup .ova file of the vm running in VirtualBox
# Set values for service, vm, time stamp, backup path, email address
# and log file name.
# NOTE: Must have ssmtp package installed and configured to be able 
# to have the log/status email sent. You must have have the systemctl and 
# ssmtp commands set for sudoers with no password.

app_name="SnipeIt"
service_name="snipe-it.service"
vm_name="snipeit"
time_stamp=$(date +%m-%d-%Y-%H-%M-%S)
backuppath="/home/mladmin/Backups/snipeit"
email_receipient="rflemen@gamil.com"
log_file_name="/home/mladmin/Backups/logs/${time_stamp}_backup.log"

# Header for the logfile
echo "*************************************" >> "${log_file_name}"
echo "${app_name} VM Monthly Backup" >> "${log_file_name}"
echo >> "${log_file_name}"
echo "*************************************" >> "${log_file_name}"
echo "Run Date & Time: ${time_stamp}" >> "${log_file_name}"
echo >> "${log_file_name}"

# Create a folder with a date/time stamp for a name
echo "---Creating Date Stamped Directory---" >> "${log_file_name}"
mkdir -p "${backuppath}/${time_stamp}"
if [ $? == 0 ]; then
        echo "SUCCESS! Directory created!" >> "${log_file_name}"
        echo >> "${log_file_name}"
else
        echo "Something went wrong!" >> "${log_file_name}"
        echo >> "${log_file_name}"
fi

# Stop the service
echo "---Stopping ${service_name}---" >> "${log_file_name}"
sudo systemctl stop "${service_name}" >> "${log_file_name}" 2>&1
if [ $? == 0 ]; then
        echo "SUCCESS! ${service_name} stop command issed!" >> "${log_file_name}"
        echo >> "${log_file_name}"
else
        echo "Something went wrong!" >> "${log_file_name}"
        echo >> "${log_file_name}"
fi

#Export a copy of the vm to a .ova file
echo "---Exporting VM to an .ova File---" >> "${log_file_name}"
echo "Starting to export the VM to an .ova file..." >> "${log_file_name}"
VBoxManage export "${vm_name}" -o "${backuppath}/${time_stamp}/${vm_name}.ova" >> "${log_file_name}" 2>&1
echo  >> "${log_file_name}"

# Start the service
echo "---Starting ${service_name}---" >> "${log_file_name}"
sleep 20
sudo systemctl start "${service_name}" >> "${log_file_name}" 2>&1
if [ $? == 0 ]; then
        echo "SUCCESS! ${service_name} start command issued!" >> "${log_file_name}"
        echo >> "${log_file_name}"
else
        echo "Something went wrong!" >> "${log_file_name}"
        echo >> "${log_file_name}"
fi

#Checking the status of the service and appending to log
echo "---Checking status of ${service_name}---" >> "${log_file_name}"
sleep 10
currently_running=$(systemctl status "${service_name}" | grep -o running)
currently_failed=$(systemctl status "${service_name}" | grep -o failed)

if [[ "$currently_running" == "running" ]]; then
        echo "HOORAY!!! ${service_name} is most definitely UP and ${currently_running}!!!" >> "${log_file_name}"
elif [[ "$currently_failed" == "failed" ]]; then
        echo "OH NO!!! The ${service_name} ${currently_failed} to start and is NOT running!!!" >> "${log_file_name}"
else
        echo "Well shit, something went HORRIBLY wrong!!!" >> "$log_file_name}"
fi
echo >> "${log_file_name}"
echo "Thank you and have a great day!!!" >> "${log_file_name}"

# Send a copy of the logfile to interested parties
cat "${log_file_name}"  | sudo ssmtp "${email_receipient}"

# *********************Future Enhancements********************
# TBD