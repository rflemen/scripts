#!/bin/bash
#Simple enumeration script
# Version 1
# Rob Flemen


#### F U N C T I O N S ####

function check_for_success () {
        sleep 1
        if [ $? == 0 ]; then
                echo -e  "\033[32m[\xE2\x9C\x94]     Command successfully executed\033[0m"
        else
                echo -e  "\033[31m[x]       Something went wrong\033[0m"
                exit 1
        fi
}


function check_reqs () {
        if command -v $1 &> /dev/null; then
                echo -e "\033[32m[\xE2\x9C\x94] Package ${1} installed\033[0m"
        else
                echo -e "\033[31m[X]            The ${1} package is not installed\033[0m"
                exit 1
        fi
}


#### M A I N ####

# Check for appropriate number of arguements
if [ $# -ne 1 ]; then
        echo -e "ERROR - usage: test.sh <ip subnet>"
        exit 1
fi


# Check prerequisites are installed
echo -e "\033[32m[+] Checking prerequisites\033[0m"
check_reqs "nmap"
check_reqs "arp-scan"


# Determine IP address and subnet of the machine the script is being run on
echo -e "\033[32m[?] Determining your IP address...\033[0m"
sleep 1
IP=$(ifconfig | grep broadcast | cut -d ' ' -f10)
check_for_success $?
echo -e "\033[32m[\xE2\x9C\x94]         Your IP is: ${IP}!\033[0m"
SUBNET=$(echo ${IP} | cut -d '.' -f1,2,3)
echo -e "\033[32m[\xE2\x9C\x94]         The subnet is ${SUBNET}\033[0m"


# Running nmap ping scan and trimming the results
echo -e "\033[32m[+] Running nmap ping scan on $1, excluding ${IP}\033[0m"
nmap -sn $1 | grep -wv "${IP}" | grep "Nmap scan" | grep -v "_gateway" | awk -F'report for ' '{print $2}' >> scan_temp.txt
check_for_success $?


# Running arp-scan and trimming the results
echo -e "\033[32m[+] Running arp-scan on $1, excluding ${IP}\033[0m"
arp-scan -I eno1 $1 2> /dev/null | grep -v "Interface:" | grep -oP '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b' >> scan_temp.txt
check_for_success $?


# Cleaing up the file, sorting,  and removing dupes
cat scan_temp.txt | sort -t . -n -k 4,4 | uniq >> scan_results_clean.txt

# Running service detection scan on IP addresses found on network

echo -e "\033[32m[+] Running final nmap service detectionping on $1, excluding ${IP}\033[0m"
nmap -q -sV -T5 -iL ./scan_results_clean.txt -oG final_scan.txt

# Cleanup files created
rm scan_temp.txt
rm scan_results_clean.txt