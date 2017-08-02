#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear
# Begin
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

# rm old nodejs install the new edition

rm -rf /usr/bin/node
yum autoremove -y nodejs
curl -sL https://rpm.nodesource.com/setup_6.x | bash -
yum install -y nodejs
ln -s /usr/bin/node /usr/bin/nodejs

#Download GhostBlog

mkdir /var/www
cd /var/www/
rm -rf ghost
curl -L https://github.com/TryGhost/Ghost/releases/download/0.11.11/Ghost-0.11.11.zip -o ghost.zip
unzip -uo ghost.zip -d ghost
rm -rf ghost.zip
chmod 755 /var/www/ghost

#install GhostBlog

cd /var/www/ghost
npm install --production
mv config.example.js config.js

echo "sed -i 's/my-ghost-blog.com/"$URL"/g' config.js" > setconfig.sh
echo "sed -i 's/localhost:2368/"$URL"/g' config.js" >> setconfig.sh
sh setconfig.sh
rm -rf setconfig.sh
sed -i 's/data\/ghost/data\/#ghost/g' config.js
rm -rf /var/www/ghost/content/data/*.db

# install forever keep Ghost online

npm install forever -g
forever stopall
forever start /var/www/ghost/index.js
sed -i '/forever start \/var\/www\/ghost\/index.js/d' /etc/rc.d/rc.local
sed -i '/exit 0/d' /etc/rc.d/rc.local
echo "forever start /var/www/ghost/index.js" >> /etc/rc.d/rc.local
echo "sleep 5" >> /etc/rc.d/rc.local                   # Restarting nginx in 3 seconds after reboot
echo "service nginx restart" >> /etc/rc.d/rc.local     #to fix the "502 bad gateway" of nginx in CentOS7
echo "exit 0" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

# install watchdog make sure vps always alive

yum install -y watchdog

# install nginx echo config in ghost.config

yum install -y nginx

cd /etc/nginx/conf.d/
rm -rf *
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
echo "####################################################################"
echo ""
echo " >>> Your blog : https://"$URL
echo " >>> All GhostBlog files install in : /var/www/ghost"
echo " >>> Database : /var/www/ghost/content/data/#ghost-dev.db"
echo " >>> Nodejs : "`node -v`"    npm : "`npm -v`
