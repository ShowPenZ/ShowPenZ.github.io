---
title: lgv40 韩版(v409n) bootloader 解锁教程（1）
date: 2020-12-01 23:47:08
tags: 安卓手机解锁
categories: 搞机
---
    网购了一个洋垃圾 LGv40(v409n)韩版的 没有在大陆发售 cpu版本为高通骁龙845
此机基于aosp所以存在很多不能用的地方比如ntp服务器是谷歌的也就导致没法自动获取时间这很蛋疼
加上谷歌真正的全家桶一堆谷歌的app往里手机里塞却不能卸载有点强迫症犯了，最蛋疼的是好几个韩文的应用我看了头都大，基于此我想把手机root玩玩 用比较流行的magisk注入然后pacth本系统的boot.img得到新的patched-boot.img 最后刷入手机获取root权限，话不多说开始。
<!--more-->

1. 首先，我大意了啊，没有闪.直接用原来的老一套去解锁bootloader，打开LG的developer网站[https://developer.lge.com/resource/mobile/RetrieveBootloader.dev]找到LG设备如何解锁bootloader网站有详细步骤，接着打开supported devices 发现LGV40 是有支持不过不是这个机型，怎么办，官方文档里不支持我这种机型的解锁，不慌我们有备而来。
2. 既然没有支持的机型![image.png](https://i.loli.net/2020/12/02/cveCQq3oGd7iOYB.png)
(图表中只有欧版的）没事我们刷呗。开头，提前下载对应机型的LG的kdz(你可以理解为rom包)[https://lg-firmwares.com/android-9-pie/]我准备刷成欧版的所以找V405EBW,机型输入完下面有很多可选的挑个你顺眼的 当然我建议选这个===>V405EBW20c_00_OPEN_EU_DS_OP_0905.kdz![image.png](https://i.loli.net/2020/12/02/gzv6TaNV3lKB4ny.png) LG fanclub有提供刷机工具[https://lg-firmwares.com/how-to-flash/],两种==>LG UP和LG Flash tool 2014.(我个人推荐LG UP).接下来提供的是LG UP的使用教程。
1. 首先将LG UP下载下来备用，然后破解替换里面的一些文件之所要破解替换，你直接下载来打开用就知道了。如果不破解的话存在不用使用的情况现在我们来介绍破解LG UP教程，首先打开这个网站下载国外修改过的LGUP——DualMolda.zip[https://www.androidfilehost.com/?fid=11410963190603845019]下载完成后，启动入文件夹内的LGUP_Store_Frame_Ver_1_14_3.msi，并安装，右键以管理员模式运行脚本运行SetDev.bat脚本就可以了（事先关闭所有打开中的LGUP）,最后最重要的就是打开原来的备用的原始版本的LG UP你就会发现可以使用了![image.png](https://i.loli.net/2020/12/02/n45hM3mLAgQPWdv.png)这里着重讲下圈起来的刷机模式partition dl 这个模式支持我们的混刷也就是支持将我们的韩版或者其他的版本刷成想要的版本，所以勾选它，把kdz拖到下面的filetype那一栏，选中partition dl模式点击start。。。 嗯？ 怎么进入刷机模式连不上LGUP呀！giao！ 忘记说了要用LG UP进行刷机必须要进去LG的Download模式 在这个模式中可以进行kdz的刷入。问题来了如何进入了，关机状态下按住音量键+号 插入usb即可自动进入下载模式 然后点击LG up的start的按钮运行一会儿之后会弹出一个选择页面 点击select all 按然start就行(如果想保存数据取消勾选userdata)等待全自动自动刷入大约3分钟。
