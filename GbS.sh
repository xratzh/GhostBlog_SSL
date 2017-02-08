#!/bin/bash

#Check system
if [[ -f /etc/redhat-release ]]; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/yum.sh  
    sudo sh yum.sh
    rm yum.sh
elif cat /etc/issue | grep -Eqi "debian|ubuntu"; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh  
    sudo sh deb.sh
    rm deb.sh
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/yum.sh  
    sudo sh yum.sh
    rm yum.sh
elif cat /proc/version | grep -Eqi "debian|ubuntu"; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh  
    sudo sh deb.sh
    rm deb.sh
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/yum.sh  
    sudo sh yum.sh
    rm yum.sh
fi
