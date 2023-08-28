#/bin/bash
# CONCERTO STATUS CHECK SCRIPT v1
# Author: Rob Flemen    Email: rflemen@gmail.com
# REQUIRES: ssmtp package. Need systemctl and ssmtp set for sudoers with no password.

# Global variables
date_stamp=$(date +%m-%d-%Y)
log_file_name="/home/concerto/logs/${date_stamp}_concerto_status.log"
email_recipient="rflemen@gmail.com"
site="192.168.0.20"
drive="sda1"

# Funtion to send email. Args: (1)log file name, (2)email address
function email_log () {
        cat $1 | sudo ssmtp $2
}

# Function to check if a command executed. Args: (1)result code, (2)log file name, (3)email address
function check_for_success () {
        if [ $1 == 0 ]; then
                echo "Command successfully executed!" >> $2
        else
                echo "Something went wrong!" >> $2
                email_log $2 $3
                exit 1
        fi
}

# Function to check the status of site and indicate up or down. Args (1)site, (2)log file name
function get_site_status () {
if wget --spider -S $1 2>&1 | grep -w "200\|301" >> $2 ; then
    echo $1 "is up" >> $2
else
    echo $1 "is down" >> $2
    email_log $2 $3
    exit 1
fi
}

# Function to check connectivity of a site and return time stats.
function get_site_stats () {
curl -s -w 'Lookup time:\t%{time_namelookup}\nConnect time:\t%{time_connect}\nPreXfer time:\t%{time_pretransfer}\nStartXfer time:\t%{time_starttransfer}\nTotal time:\t%{time_total}\n' \
        -o /dev/null $1 >> $2
}

# Header for the log file
echo "Current Concerto Status Script" >> "${log_file_name}"
echo "***************************************" >> "${log_file_name}"
date >> "${log_file_name}"
echo >> "${log_file_name}"

# Checking response of the website.
echo "1.) CHECKING STATUS OF CONCERTO:" >> "${log_file_name}"
get_site_status "${site}" "${log_file_name}" "${email_recipient}"
check_for_success $? "${log_file_name}" "${email_recipient}"
echo  >> "${log_file_name}"

echo "2.) CHECKING CONNECTIVITY TO CONCERTO:" >> "${log_file_name}"
get_site_stats "${site}" "${log_file_name}"
check_for_success $? "${log_file_name}" "${email_recipient}"
echo  >> "${log_file_name}"

# Dumping the current disk space available.
echo "3.) CHECKING DISKSPACE:" >> "${log_file_name}"
echo "...checking disk space..." >> "${log_file_name}"
percent_free=$(df -h | grep "${drive}" | xargs | cut -d ' ' -f 5)
check_for_success $? "${log_file_name}" "${email_recipient}"
echo "Disk space consumed is:" "${percent_free}" >> "${log_file_name}" 2>&1

# Send a copy of the logfile to interested parties
email_log "${log_file_name}" "${email_recipient}"
