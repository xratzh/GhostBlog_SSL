#!/bin/bash

#Check to make sure script is being run as root
if [[ `whoami` != root ]]; then
    echo "This script must be run as root"
    exit 1
fi

#Check to see what OS is being used and start run the scripts

/bin/uname -a > /tmp/osversion.txt

if grep "Ubuntu" "/tmp/osversion.txt" > /dev/null; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh  
    sudo sh deb.sh
    rm deb.sh
elif grep "SMP" "/tmp/osversion.txt" > /dev/null; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/yum.sh  
    sudo sh yum.sh
    rm yum.sh
elif grep "Debian" "/tmp/osversion.txt" > /dev/null; then
    echo "Mac OS X"
fi
