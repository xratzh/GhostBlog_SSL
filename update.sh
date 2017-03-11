#!/bin/bash

cd /var/www/
curl -L https://ghost.org/zip/ghost-latest.zip -o ghost.zip
unzip -uo ghost.zip -d ghostupdate
rm -rf ghost.zip
chmod 755 /var/www/ghostupdate
cp -f -R /var/www/ghostupdate/core /var/www/ghost/core
cd ghost
npm install --production
rm -rf /var/www/ghostupdate
