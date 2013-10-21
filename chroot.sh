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


################################
#Check version and print it out#
################################
echo "Checking the Distro Type and Version"
if [ -s /etc/redhat-release ]; then
        DIST_VER="$(cat /etc/redhat-release)"
        DIST_NUM="$(cat /etc/redhat-release|awk '{print $3}')"
        echo $DIST_VER "$GREEN"  "[OK]" $NORMAL
else
        DIST_VER="$(lsb_release -d|awk '{print $2" "$3}')"
        DIST_NUM="$(lsb_release -r|awk '{print $2}')"
        echo $DIST_VER "$GREEN" "[OK]" $NORMAL;
fi

############################
#Define Domain and Username#
############################

echo "Please enter desired username: ";
read USERNAME
echo "What is the directory to jail to?: ";
read CHROOT_DIR

###############################
#Quick check of logged in user#
###############################
#This isnt quite working right yet.


WHOAMI="$(whoami)"
if [ $WHOMAI == $USERNAME ]; then
        echo 'You cannot modify the account you are logged in as' "$RED" "[FAIL]" $NORMAL
	exit
else
        echo 'You are using a correct account' "$GREEN" "[OK]" $NORMAL
fi


############################
#Password Generator Section#
############################
echo "Generating Complex Password: ";

function randpass(){
  [ "$2" == "0" ] && CHAR="[:alnum:]" || CHAR="[:graph:]"
    cat /dev/urandom | tr -cd "$CHAR" | head -c ${1:-32}
    echo
}

PASSWORD="$(randpass 10 0)"


##############
#Create Group#
##############
echo "Creating new user...";

GROUP_CHECK="sftponly"
GROUP_COMPARE="$(getent group|grep sftponly|awk '{gsub(":", " ");print $1}')"
if [ $GROUP_CHECK != $GROUP_COMPARE ]; then
	echo "Creating sftpgroup";
	groupadd sftponly
        echo 'Group sftponly added sucessfully' "$GREEN" "[OK]" $NORMAL

else
        echo 'sftponly group already created' "$GREEN" "[OK]" $NORMAL
fi

################
#Create Account#
################

USER_CHECK="$(cat /etc/passwd|grep $USERNAME|awk '{gsub(":", " ");print $1}')"

if [ $USER_CHECK = $USERNAME ]; then
	echo "Modifying exising User";
	usermod -s /bin/false -G sftponly -d $CHROOT_DIR $USERNAME
	
else
	echo "Creating new user";
	useradd -s /bin/false -G sftponly -d $CHROOT_DIR $USERNAME
	echo "Adding Password..."
	echo $PASSWORD|passwd "$USERNAME" --stdin
	echo "User Creds: ";
	echo "Username: "$USERNAME
	echo "Password: "$PASSWORD
fi


#######################################
#Check for bad backport CentOS Version#
#######################################

if [ $DIST_NUM = "5.8" ]; then
        echo 'This version is not supported, sorry.' "$RED" "[FAIL]" $NORMAL
	exit
else
        if [ -s /etc/ssh/sshd_config ]; then
                echo "Checking sshd_config...";
                SUBSYSTEM="$(grep Subsystem /etc/ssh/sshd_config|awk '{print $3}')"
                SUBSYS_LN="$(grep -n Subsystem /etc/ssh/sshd_config|awk '{gsub(":", " ");print $1}')"
                SUBSYS_NEW='internal-sftp'
                SUBSYS_OLD='/usr/libexec/openssh/sftp-server'

                  if [ $SUBSYSTEM == $SUBSYS_NEW ]; then
                                echo "Subsystem already set!";
                        else
                                echo "Switching Subsystem for sFTP Chroot support";
                                echo "Removing Old Subsytem directives"; 
				sed '/Subsystem/d' /etc/ssh/sshd_config>/etc/ssh/sshd_config
				echo "Adding new Subsystem Directives and Mappings";
					echo "Subsystem       sftp    internal-sftp">>/etc/ssh/sshd_config
					echo "Match Group sftponly">>/etc/ssh/sshd_config
					echo "        ChrootDirectory %h">>/etc/ssh/sshd_config
					echo "        ForceCommand internal-sftp">>/etc/ssh/sshd_config
					echo "Would you like to reload sshd? (Y/n)"
					read SSHD_RESTART
				if [ "$SSHD_RESTART" == Y ]; then
					service sshd restart
				else
					if [ "$SSHD_RESTART" == n ]; then
						echo "sshd will not be restarted";
					else
						echo "Please check what you typed and try again.";
					fi
				fi
                        fi
        else
                echo "You dont seem to have an sshd_config file, you sure this is a server?"
                exit
        fi
fi

