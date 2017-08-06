#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Check system and install
if [[ -f /etc/redhat-release ]]; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/rpm.sh  
    sudo bash rpm.sh
    rm rpm.sh
elif cat /etc/issue | grep -Eqi "debian|ubuntu"; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh  
    sudo bash deb.sh
    rm deb.sh
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/rpm.sh  
    sudo bash rpm.sh
    rm rpm.sh
elif cat /proc/version | grep -Eqi "debian|ubuntu"; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh
    sudo bash deb.sh
    rm deb.sh
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/rpm.sh  
    sudo bash rpm.sh
    rm rpm.sh
fi
