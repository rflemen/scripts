#!/bin/bash
#
# Script to run a backup of Snipe-IT data and copy it to a USB drive
# Written by: R. Flemen
# To be run via root's crontab at 5 am every day
# Use logrotate to keep 14 most recent backups on USB drive

# Move to the proper directory to runa backup
cd /var/www/html/snipe-it

# Command to run a backup of Snipe-IT via command line
php artisan snipeit:backup

# Navigate to the directory where backup is located
# copy the newly created backup to the USB drive mount point
cp /var/www/html/snipe-it/storage/app/backups/*.zip /Backups

# Remove backup after it was copied to the USB drive
rm /var/www/html/snipe-it/storage/app/backups/*.zip
