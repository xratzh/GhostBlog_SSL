##A script to install ghost blog with ssl automatically
------

```
wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/GbS.sh  

sudo sh GbS.sh

```
---  

##You can do it yourself manually

- For "apt" get-package based
```
wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh  

sudo sh deb.sh
```  

- For "yum" get-package based
```
wget https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/yum.sh  

sudo sh yum.sh
```  

---
1. Enter your domain(`no-www`,or you need to edit ghost.conf)
2. Soon later,Choose 'Y'
3. Enter your email address  

---  
##Tips  

- In yum.sh,"sleep 3" in /etc/rc.d/rc.local is to fix "502 bad gateway" in CentOs7 after reboot(3 seconds later to restart nginx service).The number can be changed,but don`t less than 2 seconds.It seems necessary for CentOS7,no matter with CentOS6 and etc.  
- "ghost.conf" in /etc/nginx/ rewrite `www.yourdomain.com` to `yourdomain.com`,if you never need it,you can delete `www.${URL}`
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
- Certbot-auto will renew your SSL on the 1st every 2 months.(crontab job)  

---  
##Packages  
- curl
- unzip
- nodejs
- forever（or you can use pm2）
- watchdog
- nginx
- certbot-auto

---
##LICENSE  
MIT
