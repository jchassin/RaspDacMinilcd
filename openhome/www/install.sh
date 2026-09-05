#!/bin/bash

start_time="$(date +"%T")"
echo "* Installing : web pages"
echo "" > install_log.txt

# ---------------------------------------------------
# Make the control script a global command
rsync -a --delete \
    --chown=root:www-data \
    "./html/" \
    /var/www/html/

find /var/www -type d -exec chmod 0755 {} \;
find /var/www -type f -exec chmod 0644 {} \;

# ---------------------------------------------------
# Say something nice and exit
echo "* End of installation : web pages"
echo started at $start_time finished at "$(date +"%T")" >> install_log.txt
exit 0
