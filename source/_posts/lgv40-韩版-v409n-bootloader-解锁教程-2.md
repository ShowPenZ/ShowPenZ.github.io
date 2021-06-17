---
title: lgv40 韩版(v409n) bootloader 解锁教程(2)
date: 2020-12-03 13:33:22
tags:
---
接上教程(1)，此教程为无法通过官方提供的unlock.bin解锁的手机制作的。
还有一个事v409n也就是韩版v40可能存在无法开启fastboot模式
因为fastboot模式默认被download模式覆盖了所以想进入fastboot得先通过高通9008刷机模式下把abl_a.img 替换成v35.img(材料包里) 破坏掉开机的bootloader相关检索从而曲线进入fastboot模式。
bootloader解锁相关用的材料[https://pan.baidu.com/s/14RG4a2QTxZcGphfNagERUg](提取码: 24dn)
<!--more-->

下面是具体操作：
1.首先下载好高通9008 安装包这个网络上资源众多 不赘述
2.进入lgv40开发者模式，打开允许oem设备解锁开关(很重要)
3.连接手机与pc 进入高通手机的9008模式 如何进入呢 lgv40 同时按住音量减与电源键会截屏一下然后出现倒计时重启在倒计即将为0(或者闪烁的一瞬间)时松掉其他按键同时快速连按音量加键屏幕就会黑掉并且不再亮起，可以在设备管理器的页面看到已经连接到某个com口，类似这个图![image.png](https://i.loli.net/2020/12/07/WAFsOh4PrucLlTt.png)这就表示成功连接了9008模式。
4.打开高通qpst
    (1). 选择 Flat Build模式
    (2). 将右下角底部的storage type选到ufs
    (3). 点击Select Programmer 右侧的Browse 按钮将材料包里的prog_ufs_firehose_Sdm845_lge.elf文件选中
    (4). 点击软件顶部Tools工具选择Partition Manager等待数秒会弹出一个窗口找到abl_a
    (5). 右键abl_a 选择Manage Partition Data，会再次弹出一个窗口点击Load Image选择材料包的v35.img,然后一个个窗口关闭等待文件写入几秒
    (6). 按住音量键减与电源键强制重启会出现一个红色三角的提醒标志，不用在意数秒后会自动重启进入到fastboot模式。
    (7). 下载adb，fastboot等工具[https://developer.android.com/studio/releases/platform-tools#%E4%B8%8B%E8%BD%BD-dynamic_data.setvar.dialog_product_name]下载完成后在下载好的文件夹内打开cmd，或者将下载好的文件夹拖入cmd,在cmd 中输入<code>fastboot oem unlock</code>,到此步奏已经解开了bootloader.
    (8). 现在把abl_a.img换回前面的就可以了<code>fastboot flash abl_a 你的img路径/ablpiestock.img</code>,然后重启开机就行直接按音量键减和电源键，材料包ablpieStock.img里的是安卓9的。如果材料包里的刷回去发现不能开机还是进入fastboot模式,没关系还有办法拿到本机原配的abl_a.img(下面会说)会有如何提取系统原装的一些镜像比如boot.img以及abl.img
    
在步骤7的时候如果你有magisk补丁过patchedboot.img(也就是用magisk root掉原版的boot.img) 也可以将此刷入<code>fastboot flash boot_a 你的img路径/patchedboot.img</code>

如何解压出kdz里面的一些需要替换的镜像？
   教程一提供了下载kdz的地址，下载完kdz并且用LG UP刷机时我们可以同时解压出kdz步奏如下
   (1). cmd里下载好python (如何下载百度下)
   (2). 在cmd中输入python -m pip install zstandard
   (3). 下载kdztools[https://github.com/SGCMarkus/kdztools/archive/master.zip] 解压出来
   (4). 将下载好的kdz拷贝到kdztools的文件夹下在这个文件夹目录下打开cmd 输入 unkdz.py -f '你的kdz' -x 这将会解压出一个kdzextracted文件夹在kdztools文件夹里，打开kdzextracted文件夹将xxx.dz 文件的名字改为fw.dz 
   (5). 在kdzextracted文件夹里打开cmd，也可以通过路径在cmd 输入命令 undz.py -f kdzextracted/fw.dz -s，等个几分钟，注意磁盘够不够解压出来挺大的。最终会生成一个dzextracted文件夹各种镜像都在里面比如abl_a.img(abl_b.img和abl_a.img 是一个东西b是a的备份)，boot_a.img. 救砖的时候好用，比如前面的ablpiestock.img 无法正常开机就可以用高通qpst刷入本手机相同系统的abl.img刷入方法同上面的步奏相同找到abl_a 右键然后Load Image解压出来的救砖abl.img, boot.img同理