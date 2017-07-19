这里就推荐现在瓦工最有性价比的18刀的kvm吧。推荐使用ubuntu，比较简单，版本推荐14.04或者16.04。

主机购买可以走一波aff，[https://bwh1.net/aff.php?aff=14272&pid=43](https://bwh1.net/aff.php?aff=14272&pid=43)不喜欢的可以自己去掉，喜欢的当做支持吧。

针对不同构架选择：

首先讲三个要点，kvm要注意内核版本；要注意lotserver对应匹配版本；要注意防火墙。

## KVM

1、直接sudo apt install linux-image-3.13.0-24-generic，

2、然后再dpkg -l | grep linux-image查看自己的内核，删除linux-image-3.13.0-24-generic以外的所有内核

3、sudo apt-mark hold linux-image-3.13.0-24-generic。

4、最后update grub更新系统引导，让系统重启后，从新安装的合适的内核启动。然后reboot

- 装Ghost博客

```
https://github.com/xratzh/GhostBlog_SSL有一键安装脚本
```

- 装锐速（lotserver）

```
https://github.com/0oVicero0/serverSpeeder_kernel/blob/master/serverSpeeder.txt有关于locserver的支持列表
为了防止内核自动更新
dpkg -l | grep linux-image查看自己的内核版本
sudo apt-mark hold 自己的详细的内核版本。
https://github.com/0oVicero0/serverSpeeder_Install有在内核符合的情况下的一键安装脚本。
```

- 装$$和kcptun

```
https://github.com/xratzh/kcptun_for_ss_ssr有一键脚本，直接安装即可
```



## openvz

装Ghost博客和$$和kvm的安装过程是一样的。只是在加速这里不一样。

由于openvz不能更换内核，所以不支持锐速。可以使用rinetd，是魔改的lkl的bbr配合rinetd的。速度非常可观。

使用和方法：

```
wget https://raw.githubusercontent.com/linhua55/lkl_study/master/get-rinetd.sh
```

下载脚本，然后编辑：

输入`vi get-rinetd.sh`，按i进入编辑状态（左下角可看状态）

```
echo "2. Generate /etc/rinetd-bbr.conf"
cat <<EOF > /etc/rinetd-bbr.conf
# bindadress bindport connectaddress connectport
0.0.0.0 443 0.0.0.0 443
0.0.0.0 80 0.0.0.0 80
EOF
```

加入自己需要加速的端口，默认加速80端口（网站的http传输）和443端口（https传输），我们还需要加速我们的工具，比如我设置的8388，则加入0.0.0.0 8388 0.0.0.0 8388

```
echo "2. Generate /etc/rinetd-bbr.conf"
cat <<EOF > /etc/rinetd-bbr.conf
# bindadress bindport connectaddress connectport
0.0.0.0 443 0.0.0.0 443
0.0.0.0 80 0.0.0.0 80
0.0.0.0 8388 0.0.0.0 8388
EOF
```

完成后按ESC退出编辑状态，按`:wq`保存并退出

最后`sudo bash get-rinetd.sh`

返回`rinetd-bbr started`即加速成功。

## 防火墙

iptables在某些机器上有问题，所以推荐ufw，比较简单

安装：sudo apt install ufw -y

启用：ufw enable

设定允许哪些端口，其余端口默认不允许：ufw allow 80，就是允许80端口，加入你自己需要的端口。

还要记住记得允许自己的ssh端口（登录主机的端口，有的主机不是22端口），否则下次无法登录自己的主机，被防火墙挡在外面了。

最后运用修改后的规则：ufw reload。

ufw status可以查看目前的状态和启用了哪些端口。

完毕！
