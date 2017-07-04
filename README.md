## A script to install ghost blog with ssl automatically
------

```shell
wget --no-check-certificate -O GbS.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/GbS.sh && chmod +x GbS.sh && sudo bash GbS.sh
```
---  

## You can do it yourself manually

- For "apt" get-package based
```shell
wget --no-check-certificate -O deb.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh && chmod +x deb.sh && sudo bash deb.sh
```  

- For "yum" get-package based
```shell
wget --no-check-certificate -O yum.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/yum.sh && chmod +x yum.sh && sudo bash yum.sh
```  

---
1. Enter your domain(`no-www`,or you need to edit ghost.conf)
2. Soon later,Choose 'Y'
3. Enter your email address  

---  

## Upgrade Ghost Version

```shell
wget --no-check-certificate -O update.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/update.sh  
sudo bash update.sh
```

## Tips  

- In yum.sh,"sleep 3" in /etc/rc.d/rc.local is to fix "502 bad gateway" in CentOs7 whoes RAM is less than 512MB after reboot(3 seconds later to restart nginx service).The number can be changed,but might not less than 2 seconds.It seems necessary for CentOS7,no matter with CentOS6 and etc.  
- "ghost.conf" in /etc/nginx/ rewrite `www.yourdomain.com` to `yourdomain.com`.If you never need it,you can delete `www.${URL}` in the yum.sh or deb.sh.
- In CentOS7,firewalld may should be changed to anable 80 port and 443 port
```shell
server {
    listen 80
    server_name ${URL} www.${URL};               #rewrite www.yourdomain.com to yourdomain.com
    location ~ /.well-known {
        root /var/www/ghost;
    }
    location / {
        return 301 https://${URL}\$request_uri;
    }
}
```  
- Certbot-auto will renew your SSL on the 1st every 2 months.(crontab job)  

---
## Packages  
- iptables-persistent
- curl
- unzip
- nodejs
- forever（or you can use pm2）
- watchdog
- nginx
- certbot-auto

---
## LICENSE  
[MIT](https://github.com/xratzh/GhostBlog_SSL/blob/master/LICENSE)
