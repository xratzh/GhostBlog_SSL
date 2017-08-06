#!/bin/bash

echo "This will restart your ghost/index.js services!"

#stop nodejs with forever
forever stop /var/www/ghost/index.js

#update to the latest version of Ghost
cd /var/www/ghost
tar zcvf content.tar.gz content
mv content.tar.gz ../
cd .. && rm -rf ghost
mkdir ghost && cd ghost
npm i -g ghost-cli

#install the latest Ghost version
ghost install local
rm -rf /var/www/ghost/content
mv ../content.tar.gz . && tar zxvf content.tar.gz && rm content.tar.gz

#start nodejs and your Ghost blog

ghost restart

#update bootup settins
if [[ -f /etc/redhat-release ]]; then
    sed -i '/forever start \/var\/www\/ghost\/index.js/d' /etc/rc.d/rc.local
    sed -i '/exit 0/d' /etc/rc.d/rc.local
    echo "cd /var/www/ghost && ghost start" >> /etc/rc.d/rc.local
    echo "exit 0" >> /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
    
elif cat /etc/issue | grep -Eqi "debian|ubuntu"; then
    sed -i '/forever start \/var\/www\/ghost\/index.js/d' /etc/rc.local
    sed -i '/exit 0/d' /etc/rc.local
    echo "cd /var/www/ghost && ghost start" >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local

elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    sed -i '/forever start \/var\/www\/ghost\/index.js/d' /etc/rc.d/rc.local
    sed -i '/exit 0/d' /etc/rc.d/rc.local
    echo "cd /var/www/ghost && ghost start" >> /etc/rc.d/rc.local
    echo "exit 0" >> /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
    
elif cat /proc/version | grep -Eqi "debian|ubuntu"; then
    sed -i '/forever start \/var\/www\/ghost\/index.js/d' /etc/rc.local
    sed -i '/exit 0/d' /etc/rc.local
    echo "cd /var/www/ghost && ghost start" >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local
    
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    sed -i '/forever start \/var\/www\/ghost\/index.js/d' /etc/rc.d/rc.local
    sed -i '/exit 0/d' /etc/rc.d/rc.local
    echo "cd /var/www/ghost && ghost start" >> /etc/rc.d/rc.local
    echo "exit 0" >> /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
fi
echo "Your update has been done!Enjoy the latest version"
