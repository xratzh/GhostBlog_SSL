#/bin/sh

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
apt-get install -y curl unzip sudo

# rm old nodejs install a new edition

rm -rf /usr/bin/node
apt-get autoremove -y nodejs
curl --silent --location https://deb.nodesource.com/setup_7.x | sudo bash -
apt-get install -y nodejs

#Download GhostBlog

mkdir /var/www
cd /var/www
rm -rf ghost
curl -L https://ghost.org/zip/ghost-latest.zip -o ghost.zip
unzip -uo ghost.zip -d ghost
rm -rf ghost.zip
chmod 755 /var/www/ghost

#install GhostBlog

cd /var/www/ghost
npm install
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
sed -i '/forever start \/var\/www\/ghost\/index.js/d' /etc/rc.local
sed -i '/exit 0/d' /etc/rc.local
echo "forever start /var/www/ghost/index.js" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

# install watchdog make sure vps always alive

apt-get install -y watchdog

# install nginx echo config in ghost.config

apt-get install -y nginx
rm -rf /etc/nginx/sites-available/ghost.conf
rm -rf /etc/nginx/sites-enabled/ghost.conf

cat > /etc/nginx/sites-available/ghost.conf <<EOL
server {
    listen 80;
    server_name ${URL} www.${URL};
    location ~ ^/.well-known {
        root /var/www/ghost;
    }
    location / {
        return 301 https://${URL}$request_uri;
    }
}
EOL
ln -s /etc/nginx/sites-available/ghost.conf /etc/nginx/sites-enabled/ghost.conf
service nginx restart

# letsencryt

cd /opt && wget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto

/opt/certbot-auto certonly --no-eff-email --webroot -w /var/www/ghost -d "$URL"

# add ssl into nginx config file

cat >> /etc/nginx/sites-available/ghost.conf <<EOL
server {
    listen 443 ssl;
    server_name ${URL};
    
    root /var/www/ghost;
    index index.html index.htm;
    client_max_body_size 10G;
    
    location / {
        proxy_pass http://localhost:2368;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
     }
    ssl on;
    ssl_certificate /etc/letsencrypt/live/${URL}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${URL}/privkey.pem;
    ssl_prefer_server_ciphers On;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS;
    location ~ ^/(sitemap.xml|robots.txt) {
        root /var/www/ghost/public;
    }
    location ~ ^/.well-known {
        root /var/www/ghost;
    }
}
EOL

# restart your nginx

service nginx restart

# add a crontab job

echo '0 0 1 */2 * /opt/certbot-auto renew --quiet --no-self-upgrade' >> /var/spool/cron/crontabs/root

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
echo " >>> Database : /var/www/ghost/content/data/#ghost-dev.db"
echo " >>> Nodejs : "`node -v`"    npm : "`npm -v`
