#!/bin/bash

#Written by Nolan Berry
#nolan.berry@rackspace.com
#

echo "
░░░░░░░░░░░░░▄▄▄▄▄▄▄▄░░░░░░░░░░░░░
░░░░░░░░▄▄▄░░▀█████████░░░░░░░░░░░
░░░░░░▄█████▄▄░▀▀██████▄░██▄░░░░░░
░░░░▄██████████▄░░▀█████░░███▄░░░░
░░▄██████▀▀▀▀▀▀▀▀░░░▀███░░█████▄░░
░░░░░░░░░░░░░░░░░░░░░░░▀░░██████░░
░████████▀░░░░░░░░░░░░░░░░█████▀░░
███████▀░░░░░░░░░░░░░░░░░░███▀░▄██
█████▀░░░░░░░░░░░░░░░░░░░░█▀░░▄███
███▀░░▄█░░░░░░░░░░░░░░░░░░░░▄█████
██▀░▄███░░░░░░░░░░░░░░░░░░▄███████
░░░█████░░░░░░░░░░░░░░░░▄████████░
░░██████░░▄▄░░░░░░░░░░░░▀▀▀▀░░░░░░
░░▀█████░░███▄░░░░▄▄▄▄▄▄▄▄▄████▀░░
░░░░▀███░░█████▄░░▀██████████▀░░░░
░░░░░░▀█░░░███████▄░░▀█████▀░░░░░░
░░░░░░░░░░░█████████▄░░▀▀▀░░░░░░░░
░░░░░░░░░░░░░▀▀▀▀▀▀▀▀░░░░░░░░░░░░░
";

#################
#Format and such#
#################

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)


###############
#Are you root?#
###############
WHOAMI="$(whoami)"

	if [ $WHOAMI = root ]; then
	        echo "You are root" "$GREEN"  "[OK]" $NORMAL
	else
	        echo "Script must be run as root" "$RED"  "[ FAIL ]" $NORMAL
		exit
	fi

###################
#Set user to check#
###################
echo "What user would you like to check history for?: ";
read USERNAME

################
#How many lines#
################
echo "How many lines do you want to pull?:"
read LINES

#####################################################################
#Check Bash History For User Specified And Convert to Human Readable#
#####################################################################

echo "Converting the last $LINES lines for $USERNAME";

if [ $USERNAME = root ]; then

	tail -n $LINES /root/.bash_history | while read line; do if [[ $line =~ '#' ]];then date -d "@$(echo $line | cut -c2-)"; else echo $line ; fi; done|more

else

	tail -n $LINES /home/$USERNAME/.bash_history | while read line; do if [[ $line =~ '#' ]];then date -d "@$(echo $line | cut -c2-)"; else echo $line ; fi; done|more

fi
