##A script to install ghost blog with ssl automatically
------

```
wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/GbS.sh  

sudo sh GbS.sh

```
------  



##Or you can do it yourself manually

For "apt" get-package based
```
wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh  

sudo sh deb.sh
```  

For "yum" get-package based
```
wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/yum.sh  

sudo sh yum.sh
```  

------
1. Enter your domain
2. Choose 'Y'
3. Enter your email address  

------  
##Tips  

* In yum.sh,"sleep 3" in /etc/rc.d/rc.local is to fix "502 bad gateway" when reboot(3 seconds later to restart nginx service)，the number can be changed,but don`t less than 2 seconds.  
* "ghost.conf" in /etc/nginx/ rewrite "www.yourdomain.com" to "yourdomain.com”
```
server {
    listen 80
    server_name ${URL} www.${URL};               #rewrite www.yourdomain.com to yourdomain.com
    location ~ ^/.well-known {
        root /var/www/ghost;
    }
    location / {
        return 301 https://${URL}\$request_uri;
    }
}
```
