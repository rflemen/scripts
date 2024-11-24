#/bin/bash
# CONCERTO STATUS SCRIPT
# Author: Rob Flemen
# Requires ssmtp, curl, wget packages; ssmtp as sudoer w/ no password

# Global variables
application="CONCERTO"
date_stamp=$(date +%m-%d-%Y)
log_file="/home/concerto/logs/concerto_status.log"
current_dir="/usr/share/concerto/tmp/cache"
site="http://192.168.0.20"
drive="sda1"
threshold="20"

# Determine the number of directories in current directory
cd "${current_dir}"
num_of_dirs=$(ls -d */ 2>&1 | wc -l) 2>&1

# Header for log file.
echo >> "${log_file}"
date >> "${log_file}"
echo >> "${log_file}"
echo "****************************************************" >> "${log_file}"
echo "* HOME ${application} Status & Maint. Script *" >> "${log_file}"
echo "****************************************************" >> "${log_file}"

# Checking the status of site using http codes.
echo "1.) CHECKING STATUS OF ${application}:" >> "${log_file}"
if wget --spider -S "${site}" 2>&1 | grep -w "200\|301" >> "${log_file}" ; then
    echo "${site} is up" >> "${log_file}"
else
    echo "${site} is down" >> "${log_file}"
fi

# Checking connectivity using curl.
echo >> "${log_file}"
echo "2.) CHECKING CONNECTIVITY TO ${application}:" >> "${log_file}"
curl -s -w 'Lookup time:\t%{time_namelookup}\nConnect time:\t%{time_connect}\nPreXfer time:\t%{time_pretransfer}\nStartXfer time:\t%{time_starttransfer}\nTotal time:\t%{time_total}\n' \
        -o /dev/null "${site}" >> "${log_file}"

# Clear the cache file.
echo >> "${log_file}"
echo "3.) CLEARING THE ${application} CACHE FILES:" >> "${log_file}"
echo "Current directory is: ${current_dir}" >> "${log_file}"
echo "There are currently ${num_of_dirs} directories in the cache." >> "${log_file}"
echo "...removing the cache w/ bundle rake command..." >> "${log_file}"
sudo bundle exec rake tmp:clear >> "${log_file}"
num_of_dirs=$(ls -d */ 2>&1 | wc -l) 2>&1
echo "There are now ${num_of_dirs} directories in the cache." >> "${log_file}"

# Dumping the percentage of used hard dive
echo >> "${log_file}"
echo "4.) CHECKING ${application} DISK SPACE:" >> "${log_file}"
echo "...checking disk space..." >> "${log_file}"
percent_full=$(df -h | grep "${drive}" | xargs | cut -d ' ' -f5 | cut -d "%" -f1)
percent_free=$((100-${percent_full}))
if [ "${percent_full}" -ge "${threshold}" ]; then
        echo "The hard drive is GOOD with ${percent_free}% free space!" >> "${log_file}"
else
        echo "DANGER!!! The hard drive only has ${percent_free}% free space!" >> "${log_file}"
fi
echo >> "${log_file}"
echo "Have a great day!" >> "${log_file}"

# Emailing the log to interested parties
cat "${log_file}" | sudo ssmtp <insert email address>

