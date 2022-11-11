#!/bin/bash

start_time="$(date +"%T")"
starting_dir=${PWD}

echo "***   Installation of RaspDacMiniLCD for Openhome Audio" 
echo "https://github.com/jchassin/ohPlayer
echo "***   _____________________________________" 

# Install modules
for file in "$starting_dir"/*
do 
    test -f $file/install.sh && cd $file && bash $file/install.sh 
    cd $starting_dir
done

# ---------------------------------------------------
# Say something nice and exit
echo "* End of installation : RaspDacMiniLCD for Openhome Audio"
echo started at $start_time finished at "$(date +"%T")"
exit 0
