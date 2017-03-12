#!/bin/bash

cd /var/www/ghost
tar zcvf content.tar.gz content
mv content.tar.gz ../
mv config.js ../
cd .. && rm -rf ghost
curl -L https://ghost.org/zip/ghost-latest.zip -o ghost.zip
unzip -uo ghost.zip -d ghost
rm -rf ghost.zip
chmod 755 /var/www/ghost
cd ghost
npm install --production
rm -rf /var/www/ghost/content
mv ../content.tar.gz . && tar zxvf content.tar.gz && rm content.tar.gz
rm /var/www/ghost/config.example.js && mv ../config.js .
