#! /bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Begin
clear
echo ""
echo "########################################################"
echo "#                                                      #"
echo "#    o--------------------------------------------o    #"
echo "#    |        Thanks for using GhostBlog_ssl      |    #"
echo "#    |  Oneclick to build your GhostBlog and ssl  |    #"
echo "#    o--------------------------------------------o    #"
echo "#                                                      #"
echo "########################################################"
echo " >>> Need you run this script use sudo !                "
echo ""
echo " # Please input your Blog's domain : "
read -p "   http://" URL

# yum update and install epel-release curl and unzip

yum update -y
yum install epel-release -y
yum install curl unzip -y

# remove old nodejs install the new edition

yum autoremove -y nodejs
rm -rf /usr/bin/node
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs
ln -s /usr/bin/node /usr/bin/nodejs

# install ghost-cli and install ghost

mkdir /var/www
cd /var/www && mkdir /var/www/ghost
cd ghost
npm i -g sqlite3 && npm i -g ghost-cli
ghost install local

# config ghost

ghost stop && mv config.development.json config.production.json
sed -i "s/http:\/\/localhost:2368/https:\/\/${URL}/g" config.production.json
ghost start

# configure in bootup

sed -i '/exit 0/d' /etc/rc.d/rc.local
echo "service nginx start" >> /etc/rc.d/rc.local
echo "cd /var/www/ghost && ghost start" >> /etc/rc.d/rc.local
echo "exit 0" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

# install watchdog make sure vps always alive

yum install -y watchdog

# install nginx echo config in ghost.config

yum install -y nginx

rm -rf /etc/nginx/conf.d/*
cat > /etc/nginx/conf.d/ghost.conf <<EOF
server {
    listen 80;
    server_name ${URL} www.${URL};                     #rewrite www.yourdomain.com to yourdomain.com
    location ~ /.well-known {
        root /var/www/ghost;
    }
    location / {
        return 301 https://${URL}\$request_uri;
    }
}
EOF

service nginx restart

# letsencryt

cd /opt && wget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto

/opt/certbot-auto certonly --webroot -w /var/www/ghost -d "$URL"

# add ssl into nginx config file


cat >> /etc/nginx/conf.d/ghost.conf <<EOF
server {
    listen 443 ssl;
    server_name ${URL};
    
    root /var/www/ghost;
    index index.html index.htm;
    client_max_body_size 10G;
    
    location / {
        proxy_pass http://localhost:2368;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header Host              \$http_host;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
    }
    ssl on;
    ssl_certificate /etc/letsencrypt/live/${URL}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${URL}/privkey.pem;
    ssl_prefer_server_ciphers on;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4:!DH:!DHE;
    add_header Strict-Transport-Security max-age=15769000;
    location ~ ^/(sitemap.xml|robots.txt) {
        root /var/www/ghost/public;
    }
    location ~ /.well-known {
        root /var/www/ghost;
    }
}
EOF

# restart your nginx

service nginx restart

# add a crontab job

cat >> /var/spool/cron/root <<EOF
0 0 1 */2 * /opt/certbot-auto renew --quiet --no-self-upgrade
EOF

clear

echo " "
echo "####################################################################"
echo "#                     Thanks agnain  ^_^                           #"
echo "#         Your SSL will update on the 1st in every 2 months        #"
echo "#                                                                  #"
echo "####################################################################"
echo ""
echo " >>> Your blog : https://"${URL}
echo " >>> All GhostBlog files install in : /var/www/ghost"
echo " >>> Database : /var/www/ghost/content/data/ghost-local.db"
echo " >>> Nodejs : "`node -v`"    npm : "`npm -v`
