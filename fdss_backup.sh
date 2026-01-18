#!/bin/bash
# EXPORT .OVA OF VIRTUALBOX VIRTUAL MACHINE
# Author: Rob Flemen
# REQUIRES: ssmtp package. Run script as root.

# Global variables
service_name="fdss-vm.service"
vm_name="fdss"
app_name="FDSS"
time_stamp=$(date +%m-%d-%Y-%H-%M-%S)
backup_path="/home/Public/Backups/fdss"
log_file_name="/home/rflemen/logs/concerto_backup.log"
email_receipient="test@gmail.com"

# Funtion to send email. Args: (1)log file name, (2)email address
function email_log () {
        cat $1 | sudo ssmtp $2
}

# Check if a command executed. Args: (1)result code, (2)log file name, (3)email address
function check_for_success () {
        if [ $1 == 0 ]; then
                echo "[-]       Command successfully executed" >> $2
        else
                echo "[x]       Something went wrong" >> $2
                email_log $2 $3
                exit 1
        fi
}

# Verify service state. Args: (1)service, (2)log file, (3)email address, (4)process ID
function verify_service_state () {
        current_status=$(systemctl status $1 | grep -oe running -oe failed -oe dead)
        if [[ "$current_status" == "running" ]]; then
                echo "[-]       ${service_name} process ID: ${4} is active." >> $2
        elif  [[ "$current_status" == "failed" || "$current_status" == "dead" ]]; then
                echo "[!]       ${service_name} process ID: ${4} is inactive" >> $2
        else
                echo "[x]       Something went wrong" >> $2
                email_log $2 $3
                exit 1
        fi
}

# Header for the logfile
echo "[+] Running ${app_name} VM backup script" >> "${log_file_name}"
echo >> "${log_file_name}"

# Create a folder with a date/time stamp for a name
echo "[+] Creating date stamped directory" >> "${log_file_name}"
mkdir -p "${backup_path}/${time_stamp}"
check_for_success $? "${log_file_name}" "${email_receipient}"

# Stop the service & verify state
echo >> "${log_file_name}"
process_id=$(ps -ef | grep "[V]BoxHeadless -s ${vm_name}" | tr -s ' ' | cut -d ' ' -f2)
echo "[+] Stopping process ID: ${process_id} - ${service_name}..." >> "${log_file_name}"
sudo systemctl stop "${service_name}" >> "${log_file_name}" 2>&1
sleep 5
check_for_success $? "${log_file_name}" "${email_receipient}"
verify_service_state "${service_name}" "${log_file_name}" "${email_receipient}" "${process_id}"

#Export a copy of the vm to a .ova file
echo >> "${log_file_name}"
echo "[+] Exporting vm to an .ova file" >> "${log_file_name}"
VBoxManage export "${vm_name}" -o "${backup_path}/${time_stamp}/${vm_name}.ova" >> "${log_file_name}" 2>&1

# Start the service & verify state
echo >> "${log_file_name}"
echo "[+] Starting ${service_name}" >> "${log_file_name}"
sudo systemctl start "${service_name}" >> "${log_file_name}" 2>&1
check_for_success $? "${log_file_name}" "${email_receipient}"
sleep 90
process_id=$(ps -ef | grep "[V]BoxHeadless -s ${vm_name}" | tr -s ' ' | cut -d ' ' -f2)
verify_service_state "${service_name}" "${log_file_name}" "${email_receipient}" "${process_id}"

# Send a copy of the logfile to interested parties
email_log "${log_file_name}" "${email_receipient}"
