#!/bin/sh
##Set vhost url

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

#######################


echo "What is the domain?"
read DOMAIN

##Check if the dir exists
echo "Checking if this folder exisits..."
if [ -d /var/www/vhosts/$DOMAIN/ ]; then
	#Print out it exisits
echo "Directory for vhost already exists!"  "$GREEN" "[OK]" $NORMAL
else
	#Make the vHost directory
echo "Making directory structure"
mkdir -p /var/www/vhosts/$DOMAIN
echo "Directory /var/www/vhosts/$DOMAIN/ Created!"  "$GREEN" "[OK]" $NORMAL
fi
####
#Make the config
####

echo "Checking webserver type"
if [ -d /etc/httpd/ ]; then
	echo "I see this is running httpd"
		if [ -s /etc/httpd/vhost.d/$DOMAIN.conf ]; then
			echo "vHost already exists."  "$RED" "[ FAIL ]" $NORMAL
		else
echo "<VirtualHost *:80>
        ServerName $DOMAIN
        ServerAlias www.$DOMAIN
        DocumentRoot /var/www/vhosts/$DOMAIN
        <Directory /var/www/vhosts/$DOMAIN>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
        </Directory>

        CustomLog /var/log/httpd/$DOMAIN-access.log combined
        ErrorLog /var/log/httpd/$DOMAIN-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>">/etc/httpd/vhost.d/$DOMAIN.conf
		fi
	if [ -s /etc/httpd/vhost.d/$DOMAIN.conf ]; then
                echo "Config created for $DOMAIN"  "$GREEN" "[OK]" $NORMAL
###Reload Section

			echo "Would you like to reload the webserver config?(Yes/No)"
			read RELOAD
			if [ $RELOAD = Yes ]; then
        		service httpd reload
		else
        			if [ $RELOAD = No ]; then
                			echo "httpd will not be reloaded."
					exit
        			else
                			echo "Plese check what you typed and try again."
        			fi
		fi

###End of reload section


 		else
			echo "Something may have gone wrong with the config creation, sorry about that"
		fi
	else
		echo "I see this is running apache2"
if [ -s /etc/apache2/sites-enabled/$DOMAIN.conf ]; then
                        echo "vHost already exists."  "$RED" "[ FAIL ]" $NORMAL
			exit
else
	echo "<VirtualHost *:80>
        ServerName ${DOMAIN}
        ServerAlias www.${DOMAIN}
        DocumentRoot /var/www/vhosts/$DOMAIN
        <Directory /var/www/vhosts/$DOMAIN>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
        </Directory>

        CustomLog /var/log/apache2/$DOMAIN-access.log combined
        ErrorLog /var/log/apache2/$DOMAIN-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>">/etc/apache2/sites-available/$DOMAIN.conf
fi
        if [ -s /etc/apache2/sites-available/$DOMAIN.conf ]; then
                echo "vHost config created!"
##Symlink it over from avail to enabled
		ln -s /etc/apache2/sites-available/$DOMAIN.conf /etc/apache2/sites-enabled/$DOMAIN.conf
		echo "Checking symlink"
		if [ -s /etc/apache2/sites-enabled/$DOMAIN.conf ]; then
			echo "Symlink looks good!" "$GREEN" "[OK]" $NORMAL
		else
			echo "There seems to be an issue with the symlink :(" "$RED" "[ FAIL ]" $NORMAL
		fi
###Reload Section

                        echo "Would you like to reload the webserver config?(Yes/No)"
                        read RELOAD
                        if [ $RELOAD = Yes ]; then
                        	if [ $WEBSERVER = httpd ]; then
					/etc/init.d/httpd reload
				else
					service apache2 reload
				fi
               		else
                        	if [ $RELOAD = No ]; then
                                	echo "apache2 will not be reloaded."
					exit
                        	else
                                	echo "Plese check what you typed and try again."
                        	fi
        		fi

###End of reload section

        else
                echo "Something may have gone wrong with the config creation, sorry about that :("
        fi
fi
exit
