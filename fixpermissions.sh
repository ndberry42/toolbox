#!/bin/sh

MYNAME=`basename "$0"`

print_help() {
	cat << EOF
Usage: $MYNAME <directory> [ file_perms  dir_perms ]
Where:
  directory   The directory to recursively apply the permissions. Use "." for
              current directory.
  file_perms  The permissions to be applied to files. (default: 644)
  dir_perms   The permissions to be applied to directories. (default: 755)

This script is meant to fix the permissions after copying files (and
directories) from filesystems that don't support UNIX-style permissions (like
FAT).

This script will recursively apply the specified permissions to all files
and directories inside the specified directory. Be careful to not change
permissions of things you don't want to change. BE EXTRA CAREFUL IF YOU TRY TO
RUN THIS AS ROOT.
EOF
}


if [ -z "$1" -o "$1" = "--help" -o "$1" = "-help" -o "$1" = "-h" ]; then
	print_help
elif [ $# != 3 -a $# != 1 ]; then
	echo "$MYNAME: Incorrect number of parameters."
	exit 1
else

	if [ "$3" != "" ]; then
		FILEPERMS="$2"
		DIRPERMS="$3"
	else
		FILEPERMS=644
		DIRPERMS=755
	fi

	#This will give read permission to all files (and directories).
	#After this command, 'find' will be able to access the entire directory tree.
	chmod -R +rx "$1"

	find "$1" -type f -exec chmod "$FILEPERMS" '{}' ';'
	find "$1" -type d -exec chmod "$DIRPERMS"  '{}' ';'
fi
