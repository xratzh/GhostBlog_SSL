## A script to install ghost blog with ssl automatically
------

# There are two editions of Ghost.*plus is the version over 1.0.0.And non-plus is the version bellow 1.0.0.

## Firewall settings
- For Ubuntu(ufw)
```shell
apt install ufw
ufw enable
ufw allow 80 && ufw allow 443
ufw reload
```
- For CentOS6(iptables for ubuntu as the same)
```shell
service iptables start
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
service iptables restart
```
- For CentOS7
```shell
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --zone=public --add-port=80/tcp --permanent  
firewall-cmd --zone=public --add-port=80/udp --permanent  
firewall-cmd --zone=public --add-port=443/tcp --permanent 
firewall-cmd --zone=public --add-port=443/udp --permanent  
firewall-cmd --reload 
```

## Usage of *plus
```shell
wget --no-check-certificate -O GbSplus.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/GbSplus.sh && chmod +x GbSplus.sh && sudo bash GbSplus.sh
```
## Usage of non-plus
```shell
wget --no-check-certificate -O GbS.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/GbS.sh && chmod +x GbS.sh && sudo bash GbS.sh
```
---  

## You can do it yourself manually

### *plus edition
- For "apt" get-package based
```shell
wget --no-check-certificate -O debplus.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/debplus.sh && sudo bash debplus.sh
```  

- For "yum" get-package based
```shell
wget --no-check-certificate -O rpmplus.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/rpmplus.sh && sudo bash rpmplus.sh
```  
### non-plus edition

- For "apt" get-package based
```shell
wget --no-check-certificate -O deb.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/deb.sh && sudo bash deb.sh
```  

- For "yum" get-package based
```shell
wget --no-check-certificate -O rpm.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/rpm.sh && sudo bash rpm.sh
```  

---
1. Enter your domain(`no-www`,or you need to edit ghost.conf)
2. Soon later,Choose 'Y'
3. Enter your email address  

---  

## Upgrade Ghost Version

### *plus
```shell
cd /var/www/ghost && ghost update
```

### non-plus
```shell
wget --no-check-certificate -O update.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/update.sh && sudo bash update.sh
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

### *plus
- curl
- sqlite3
- unzip
- nodejs
- watchdog
- nginx
- certbot-auto

### non-plus
- iptables-persistent(ubuntu)
- curl
- sqlite3
- unzip
- nodejs
- forever（or you can use pm2）
- watchdog
- nginx
- certbot-auto

---
## LICENSE  
[MIT](https://github.com/xratzh/GhostBlog_SSL/blob/master/LICENSE)
