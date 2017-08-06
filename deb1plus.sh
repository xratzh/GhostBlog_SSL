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

# apt-get update and install curl unzip
apt-get update -y
apt-get install curl unzip sudo -y

# remove old nodejs install the latest edition

rm -rf /usr/bin/node
apt-get autoremove -y nodejs
curl --silent --location https://deb.nodesource.com/setup_6.x | sudo bash -
apt-get install -y nodejs

# install ghost-cli and install ghost

mkdir /var/www
cd /var/www && mkdir /var/www/ghost
cd ghost
npm i -g ghost-cli
ghost install local

# configure in bootup

sed -i '/exit 0/d' /etc/rc.local
echo "cd /var/www/ghost && ghost start" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

# install watchdog make sure vps always alive

apt-get install -y watchdog

# install nginx echo config in ghost.config

apt-get install -y nginx
rm -rf /etc/nginx/sites-available/ghost.conf
rm -rf /etc/nginx/sites-enabled/ghost.conf

cat > /etc/nginx/sites-available/ghost.conf <<EOF
server {
    listen 80;
    server_name ${URL} www.${URL};
    location ~ /.well-known {
        root /var/www/ghost;
    }
    location / {
        return 301 https://${URL}\$request_uri;
    }
}
EOF
ln -s /etc/nginx/sites-available/ghost.conf /etc/nginx/sites-enabled/ghost.conf
service nginx restart

# letsencryt

cd /opt && wget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto

/opt/certbot-auto certonly --webroot -w /var/www/ghost -d "$URL"

# add ssl into nginx config file

cat >> /etc/nginx/sites-available/ghost.conf <<EOF
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
    location ~ ^/.well-known {
        root /var/www/ghost;
    }
}
EOF
# restart your nginx

service nginx restart

# add a crontab job

cat >> /var/spool/cron/crontabs/root <<EOF
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
