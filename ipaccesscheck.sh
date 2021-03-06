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

##########################
#Determine Webserver type#
##########################

echo "Checking webserver type(Only Supports httpd and apache2 at the moment)"
        if [ -d /etc/httpd/ ]; then
                WEBSERVER=httpd
                echo "Server running httpd";
        else
                WEBSERVER=apache2
                echo "Server running apache2";
        fi

##########################
#Check and Parse the logs#
##########################

if [ -s /var/log/$WEBSERVER/ ]; then

	DATE1="$(date|awk '{print $3}')"
	DATE2="$(date|awk '{print $2}')"
	TODAY="$DATE1"/"$DATE2"

	echo "Checking access logs for most frequent IPs from today:"
	cat /var/log/$WEBSERVER/*access*|grep $TODAY|awk '{print $1}'|sort -n|uniq -c|sort -n|tail -n 20
	echo "Getting Country Information for IPs"
	cat /var/log/$WEBSERVER/*access*|grep $TODAY|awk '{print $1}'|sort|uniq|while IFS= read -r ip ; do
   	echo $ip:$(whois "$ip"|grep 'Country'|awk '{print $2}')
	done
else
	echo "No webserver found, or logging is not setup as expected";
fi

