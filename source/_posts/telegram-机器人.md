---
title: telegram 机器人
date: 2019-12-28 14:56:29
tags: telegram
top:
categories: 
 - js
 - node
 - nginx
---

### 关于如何创建机器人以及机器人部署至线上服务器请看这篇博文

[从零开始写一个 Telegram Bot](http://anata.me/2019/03/30/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E5%86%99%E4%B8%80%E4%B8%AATelegram-Bot/)

### 以下的是我根据博文部署以及写机器人产生的一些问题

1. 线上部署时，用的是 <font color=red>centos 6.8</font> 的系统所以安装 nginx 时产生了一些和教程博客不一样的地方
   如图: 这是教程截图 ![image.png](https://i.loli.net/2019/12/28/z7ogQahDpLJ3BK2.png)

因为 centos 系统版本不一样 所以 yum 源设置也不一样 我的解决办法

```
vim /etc/yum.repos.d/nginx.repo
```

写入：
<!--more-->
```
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
```

保存退出

```
yum install nginx
```

2. 网站支持 https
   教程中 centos 7 可以直接这样 如图：
   ![image.png](https://i.loli.net/2019/12/28/fkw2rzUNmaTV5Ao.png)
   但由于我的系统为 centos 6 所以无法直接使用命令
   解决办法： 打开[certbot](https://certbot.eff.org/lets-encrypt/centos6-nginx.html) 根据教程一步步即可完成 https 加持，教程的第三步会有两种可选方式我为了省事少折腾直接选择了第一种 auto 模式，都完成了之后，第五步去验证网站是否已支持 https。

### github 已开源我的机器人
[telegram-bot](https://github.com/ShowPenZ/telegram-bot)
欢迎根据教程制作一个 telegram bot 进行娱乐消遣(x 图爬取)顺便告诫下宅男程序猿<font color=red>少打点手冲</font>
