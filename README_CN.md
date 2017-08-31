## 一键搭建Ghost博客和部署Let‘s Encrypt
---
## 有两个版本的Ghost博客：
- 0.11.11及小于此的版本，是Ghost的1-99个版本号，我命名为`*plus`
- 1.0.0及大于此的版本， 是Ghost的100个版本后的版本号码`non-plus`

#### 设定防火墙
#### ufw
- Ubuntu/Debian
```shell
apt install ufw
ufw enable
ufw allow 80 && ufw allow 443
ufw reload
```
- CentOS(ufw)
```shell
yum install -y ufw
ufw enable
ufw allow 80 && ufw allow 443
ufw reload
```
---
#### Or ipables/fillwlld
- For CentOS6(iptables for ubuntu/debian as the same)
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
### 一键使用方法

#### `*plus`
```shell
wget --no-check-certificate -O GbSplus.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/GbSplus.sh && chmod +x GbSplus.sh && sudo bash GbSplus.sh
```
#### `non-plus`
```shell
wget --no-check-certificate -O GbS.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/GbS.sh && chmod +x GbS.sh && sudo bash GbS.sh
```
 1. 输入你的域名(不带www的前缀，否则你需要自己修改默认的文件关于nginx的设定)
 2. 不久后certbot更新，需要选择'Y'
 3. 输入你的邮箱，letencrypt会到期提前提醒你  
---  
#### 升级你的Ghost版本

##### `*plus` update
```shell
cd /var/www/ghost && ghost stop && ghost update
```

##### non-plu升级到0.11.11
```shell
wget --no-check-certificate -O update.sh https://raw.githubusercontent.com/xratzh/GhostBlog_SSL/master/update.sh && sudo bash update.sh
```

##### 0.11.11升级到1.0.0及以后的版本

[官方的说明](https://docs.ghost.org/v0.11.11/docs/migrating-to-ghost-version-100)

#### 注意  

- 在rpm.sh里,/etc/rc.d/rc.local的sleep 5是用来修复CentOS7小内存有概率出现的"502 bad gateway".
- /etc/nginx/中的"ghost.conf“重定向`www.yourdomain.com`到你的`yourdomain.com`域名.如果你不需要重定向，就删除sh后缀文件中的`www.${URL}`
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
- Certbot-auto将在两月后的1日更新.(crontab job)  

---
#### 包

##### `*plus`
- curl
- sqlite3
- unzip
- nodejs
- watchdog
- nginx
- certbot-auto

##### non-plus
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
#### LICENSE  
[MIT](https://github.com/xratzh/GhostBlog_SSL/blob/master/LICENSE)
