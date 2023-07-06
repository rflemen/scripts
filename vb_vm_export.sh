#!/bin/bash
# EXPORT .OVA OF VIRTUALBOX VIRTUAL MACHINE
# Verion 2
# Author: Rob Flemen
# Email: rflemen@gmail.com

# Script to export a backup .ova file of the vm running in VirtualBox
# Set values for service, vm, time stamp, backup path, email address
# and log file name.

app_name="FDSS"
service_name="fdss-vm.service"
vm_name="fdss"
time_stamp=$(date +%m-%d-%Y-%H-%M-%S)
backuppath="/home/rflemen/Backups/fdss"
email_receipient="rflemen@gmail.com"
log_file_name="/home/rflemen/Backups/fdss/logs/${time_stamp}_backup.log"

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
if [ $? == 0 ]
then
        echo "SUCCESS! Directory created!" >> "${log_file_name}"
        echo >> "${log_file_name}"
else
        echo "Something went wrong!" >> "${log_file_name}"
        echo >> "${log_file_name}"
fi

# Stop the service
echo "---Stopping ${service_name}---" >> "${log_file_name}"
sudo systemctl stop "${service_name}" >> "${log_file_name}" 2>&1
if [ $? == 0 ]
then
        echo "SUCCESS! ${service_name} stopped" >> "${log_file_name}"
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
if [ $? == 0 ]
then
        echo "SUCCESS! ${service_name} started!" >> "${log_file_name}"
        echo >> "${log_file_name}"
else
        echo "Something went wrong!" >> "${log_file_name}"
        echo >> "${log_file_name}"
fi

#Checking the status of the service and appending to log
sleep 10
echo "---Checking status of ${service_name}, if active (running), we're good!---" >> "${log_file_name}"
systemctl status "${service_name}" | grep Active >> "${log_file_name}"
echo >> "${log_file_name}"
echo "Thanks for playing & GOODBYE!!!" >> "${log_file_name}"

# Send a copy of the logfile to interested parties
cat "${log_file_name}"  | sudo ssmtp "${email_receipient}"

# *********************Future Enhancements********************
# Save multiple copies of .ova in a folder with date of export
# Setup a monthly cron job to do the execution of the script (1 time a month)
# Create a cleanup section that deletes the oldest copy of the 12 that are saved as a new one is exported
