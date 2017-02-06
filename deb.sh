#/bin/sh

# Begin
clear
echo ""
echo "########################################################"
echo "#                                                      #"
echo "#    o--------------------------------------------o    #"
echo "#    |        Thanks for using ghostwithssl       |    #"
echo "#    | Oneclick to build your GhostBlog with ssl! |    #"
echo "#    o--------------------------------------------o    #"
echo "#                                                      #"
echo "########################################################"
echo ""
echo " >>> Work with Ubuntu (or debian)                       "
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
curl --silent --location https://deb.nodesource.com/setup_6.x | sudo bash -
apt-get install -y nodejs
ln -s /usr/bin/nodejs /usr/bin/node
apt-get install -y build-essential

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
echo 'server {' >> /etc/nginx/sites-available/ghost.conf
echo '    listen 80;' >> /etc/nginx/sites-available/ghost.conf
echo '    server_name '$URL';' >> /etc/nginx/sites-available/ghost.conf
echo '' >> /etc/nginx/sites-available/ghost.conf
echo '    location ~ ^/.well-known {' >> /etc/nginx/sites-available/ghost.conf
echo '        root /var/www/ghost;' >> /etc/nginx/sites-available/ghost.conf
echo '    }' >> /etc/nginx/sites-available/ghost.conf
echo '' >> /etc/nginx/sites-available/ghost.conf
echo '    location / {' >> /etc/nginx/sites-available/ghost.conf
echo '        return 301 https://$server_name$request_uri;' >> /etc/nginx/sites-available/ghost.conf
echo '    }' >> /etc/nginx/sites-available/ghost.conf
echo '}' >> /etc/nginx/sites-available/ghost.conf
ln -s /etc/nginx/sites-available/ghost.conf /etc/nginx/sites-enabled/ghost.conf
service nginx restart

# letsencryt

cd /opt && wget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto

/opt/certbot-auto certonly --webroot -w /var/www/ghost -d "$URL"

# add ssl config to nginx

echo '' >> /etc/nginx/sites-available/ghost.conf
echo ' server {' >> /etc/nginx/sites-available/ghost.conf
echo '     listen 443 ssl;' >> /etc/nginx/sites-available/ghost.conf
echo '     server_name '$URL';' >> /etc/nginx/sites-available/ghost.conf
echo '' >> /etc/nginx/sites-available/ghost.conf
echo '     root /var/www/ghost;' >> /etc/nginx/sites-available/ghost.conf
echo '     index index.html index.htm;' >> /etc/nginx/sites-available/ghost.conf
echo '' >> /etc/nginx/sites-available/ghost.conf
echo '     location / {' >> /etc/nginx/sites-available/ghost.conf
echo '         proxy_pass http://localhost:2368;' >> /etc/nginx/sites-available/ghost.conf
echo '         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/sites-available/ghost.conf
echo '         proxy_set_header Host $http_host;' >> /etc/nginx/sites-available/ghost.conf
echo '         proxy_set_header X-Forwarded-Proto $scheme;' >> /etc/nginx/sites-available/ghost.conf
echo '         proxy_buffering off;' >> /etc/nginx/sites-available/ghost.conf
echo '     }' >> /etc/nginx/sites-available/ghost.conf
echo '' >> /etc/nginx/sites-available/ghost.conf
echo '     ssl on;' >> /etc/nginx/sites-available/ghost.conf
echo '     ssl_certificate /etc/letsencrypt/live/'$URL'/fullchain.pem;' >> /etc/nginx/sites-available/ghost.conf
echo '     ssl_certificate_key /etc/letsencrypt/live/'$URL'/privkey.pem;' >> /etc/nginx/sites-available/ghost.conf
echo '     ssl_prefer_server_ciphers On;' >> /etc/nginx/sites-available/ghost.conf
echo '     ssl_protocols TLSv1 TLSv1.1 TLSv1.2;' >> /etc/nginx/sites-available/ghost.conf
echo '     ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS;' >> /etc/nginx/sites-available/ghost.conf
echo '' >> /etc/nginx/sites-available/ghost.conf
echo '     location ~ ^/(sitemap.xml|robots.txt) {' >> /etc/nginx/sites-available/ghost.conf
echo '         root /var/www/ghost/public;' >> /etc/nginx/sites-available/ghost.conf
echo '     }' >> /etc/nginx/sites-available/ghost.conf
echo '' >> /etc/nginx/sites-available/ghost.conf
echo '     location ~ ^/.well-known {' >> /etc/nginx/sites-available/ghost.conf
echo '         root /var/www/ghost;' >> /etc/nginx/sites-available/ghost.conf
echo '     }' >> /etc/nginx/sites-available/ghost.conf
echo ' }' >> /etc/nginx/sites-available/ghost.conf

# restart your nginx

service nginx restart

# add a crontab job

echo '0 0 1 */2 * /opt/certbot-auto renew --quiet --no-self-upgrade' >> /var/spool/cron/crontabs/root

echo "####################################################################"
echo "#                                                                  #"
echo "#             Your cerbot-auto will update every 2 months          #"
echo "#                                                                  #"
echo "####################################################################"
