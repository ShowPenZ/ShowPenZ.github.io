---
title: Hackintosh-K670-G4E6(神舟战神系列 hasse god of war serials)
date: 2020-04-26 14:09:19
tags: 
 - 黑苹果(hackintosh) 
top:
categories:
 - 玩
---

# Hackintosh-K670D-G4E6
Hackintosh for Hasse

EFI下载地址为  [Hackintosh-K670D-G4E6](https://github.com/ShowPenZ/Hackintosh-K670D-G4E6 "Hackintosh-K670D-G4E6")


### 最新提示 wtf====>HD Graphic 610 核显

Intel Pentium Gold G5420 使用的核显是Intel HD Graphic 610 
现在基本没有办法驱动这个hd 610 核显，导致电脑特别的卡以及一些观感问题 
加上这台电脑又是NVIDIA的独显，在macOS 10.13之后的版本已经没有NVIDIA的独显驱动适配了
所以我打算将macOS版本降级到10.13.6版本


### 我安装的是macOS 版本为10.14.4

| 配置 |                                                   |
| ---- | ------------------------------------------------- |
| CPU  | Intel Pentium Gold G5420  @ 3.80GHz 双核          |
| GPU  | NVIDIA GeForce GTX 1050 4GB GDDR5                 |
| 网卡 | 瑞昱RTL8168/8111/8112 Gigabit Ethernet Controller |
| 硬盘 | 镁光256GB/固态硬盘                                |
| 内存 | 8G DDR4 英睿达 2666MHZ                            |



### 使用方法 
将下载好的EFI文件夹替换U盘掉原来的EFI文件夹 

如果没有制作过u盘可以通过下面提供的工具来制作

u盘制作工具链接: https://pan.baidu.com/s/18r3plI7BTnYCG6OTY2S5KQ 提取码: b9ij 
<!--more-->


### 制作u盘启动盘方法

1. 制作启动盘 
   插入一个普通的u盘，打开u盘工具.exe(实际是Ether)，用Ether把镜像写入U盘,镜像可以去[黑果小兵大佬的blog](https://blog.daliansky.net/categories/%E4%B8%8B%E8%BD%BD/ "黑果小兵大佬的blog")下载想要的macOS版本

2. 将efi注入到启动盘
   打开黑苹果工具.exe 用管理员权限方式打开，看好u盘的盘符在制作u盘盘符那一栏选择好u盘 然后将本次提供的efi文件夹拖进这个软件界面即会自动倒入efi文件等待一段时间会提示制作成功，即可重新拔插下然后打开u盘检阅下文件

### 启动黑苹果安装

重启选择有macOS的u盘,然后点击install macOS自动跑代码 然后结束会出现苹果图标和进度条等待一会就会进去macOS实用工具，即完成了初步安装
   