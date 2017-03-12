#!/bin/bash

cd /var/www/ghost
tar zcvf content.tar.gz content
cp content.tar.gz ../
cd .. && rm -rf ghost
curl -L https://ghost.org/zip/ghost-latest.zip -o ghost.zip
unzip -uo ghost.zip -d ghost
rm -rf ghost.zip
chmod 755 /var/www/ghost
rm -rf /var/www/ghost/content
cd ghost
npm install --production
rm ../content.tar.gz
