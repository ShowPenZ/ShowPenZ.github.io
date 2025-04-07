---
title: react-float-input
date: 2019-06-20 18:41:30
tags: 
 - react
 - float input
categories: javascript
top: 
---

碰到项目需要给输入框一个小效果类似这个

![floatInput](https://i.loli.net/2019/06/20/5d0b65e9bc5c449605.gif)

大概思路将label绝对定位到input输入框内，点击input框后用transform将label缩小并上移
欢迎去npm下载使用插件 react-float-input 😊

``` bash
$ yarn add react-float-input
$ npm install react-float-input

```
<!--more-->
react dom结构
``` javascript
return (
    <div className="control">
        <input
        type={type}
        className={`input ${className}`}
        onChange={that.handleNumberChange}
        data-value={dataValueLength}
        value={inputValue}
        />
        <label htmlFor="" className="label">
        {label}
        </label>
    </div>
);
```
css 核心代码

``` html
.input {
  z-index: 0;
  height: 48px;
  padding-top: 20px;
  box-sizing: border-box;
  border: 1px solid rgba(232, 234, 239, 1);
  box-shadow: 0 2px 4px 0 rgba(32, 49, 100, 0.05);
  //点击出现效果
  &:focus + .label {
    transform: translateY(-10px) scale(0.85);
  }
  //用data-value这个钩子，当其设定值等于0时，也就是删除input内输入时，复原初始效果
  &:not([data-value='0']) + .label {
    transform: translateY(-10px) scale(0.85);
}

.label {
  position: absolute;
  top: 14px;
  left: 12px;
  z-index: 2;
  height: 20px;
  font-size: 14px;
  line-height: 20px;
  color: #000;
  pointer-events: none; // 穿透label获取焦点用
  cursor: text;
  transition: all 0.2s ease-out;
  transform-origin: top left;
} 

```
有兴趣可以尝试下 吼吼吼。。。

