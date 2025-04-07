---
title: TON 合约开发个人经历(2)
date: 2025-04-07 16:49:21
tags: Ton Func
categories: Ton 合约开发
---

接上文，开始我个人经历(2)之前请先在[入门课程](https://stepik.org/lesson/1011483/step/1?unit=1019343)开始学习从Smart contract development lifecycle学习到Mastering FunC contracts coding跟着视频或者文档一步一步敲完事例代码。

接下来的内容默认你已经懂得了基本的func以及ton链的一些知识。
首先我们以一个简单银行合约为例子：
简单银行目标就是存款，利息计算，提取本金，领取利息，以及合约所有者特权(管理权限)
在产品的角度来看用户的旅程：
1. 用户存款
2. 合约自动计算利息
3. 用户领取利息
4. 用户提取本金
