---
title: npmpkg starter
date: 2020-01-14 15:31:59
tags:
  - react
  - vue
  - npm
  - starter
top:
categories:
  - javascript
---

# npmpkg-starter-vue

A Vue NPM package starter

[项目代码地址](https://github.com/ShowPenZ/npmpkg-starter-vue)

为了简化老哥们的生产 npm 包的复杂程度
提供了一个小框架(Vue 版) 打包工具使用[bili](https://github.com/egoist/bili)
还有相应的代码规范规则以及代码提交规范

## Installation

```
$ npm i
$ yarn
```

## 用法

1. 修改<code>package.json</code>
   ![image.png](https://i.loli.net/2020/01/14/9vf1JxTrGCZmtcW.png)
   name，author，main，description，keywords 改为你需要写入的信息
   main 为打包出来的文件路口
   <br>
   <!--more-->
2. 修改<code>bill.config.js</code>
   ![image.png](https://i.loli.net/2020/01/14/VuPOGQBKrTYiphe.png)
   修改 input 打包入口文件路径 <code>src/xxxx.vue</code> 为你的文件名字，假如你的组件叫 Websocket 则改为<code>src/Websocket.vue</code><br>
   修改 moduleName 模块名字 xxxx 为你的文件模块名字 例如：<code>moduleName: 'Websocket'</code><br>
   <code>extractCSS</code> 为打包出来的 js 文件是否要包含 css 也就是不单独派生出 css 文件<br>
   <code>babel</code> 这边<font color=red>默认已经给 vue 配置了 jsx 语法</font> 已打开了<code>babelrc: true</code>, <code>.babelrc</code>文件可编写自己的所需
   <br>

3. README.md 文件写入自己的组件介绍以及 LICENSE 文件替换
   <br>

4. 书写规范的<code>.editorconfig</code> 代码规范的<code>.prettierrc</code>以及<code>.eslintrc</code>文件可以根据自己的项目需要自己修改 这些都需要 vs code 或者你使用的编辑器下载相关的插件才会生效
   <br>

5. <code>yarn build</code> 执行代码编译打包生成 dist 文件夹以及代码源文件
   <br>

6. 代码编写完 git 上传时 commit 填写规则<code>type(path): xxxx</code>
   type 必须为其中之一<code>[build, chore, ci, docs, feat, fix, improvement, perf, refactor, revert, style, test]</code>
   <code>path</code>为修改文件的路径例如 src，package 之类
   <code>xxxx 为本次修改提交</code>
   <br>

7. 默认你已经注册过 npm 账号 在发布前最好去 npm 里输入自己要发布的包名检查下是否已有相同的包 npm 的包名都是唯一的 在终端执行<code>npm publish</code>命令即可推送 npm 包(注意 package.json 的 version 版本号)<br>
   大部分的 publish 失败都是包名重复<br>
   小修改小补丁已经 bugfix 可以使用<code>npm version patch && npm publish</code>或相应脚本的代码<code>npm run release:patch</code><br>
   小升级使用<code>npm version minor && npm publish</code>或<code>npm run release:minor</code><br>
   大升级使用<code>npm version major && npm publish</code>或<code>npm run release:major</code>

# npmpkg-start-react

a React NPM package starter

[项目代码地址](https://github.com/ShowPenZ/npmpkg-start-react)

为了简化老哥们的生产 npm 包的复杂程度
提供了一个小框架(React 版本) 打包工具使用[bili](https://github.com/egoist/bili)
还有相应的代码规范规则以及代码提交规范

## Installation

```
$ npm i
$ yarn
```

## 用法

1. 修改<code>package.json</code>
   ![image.png](https://i.loli.net/2020/01/14/x8qdDzh6C1HfME4.png)
   name，author，main，description，keywords 改为你需要写入的信息
   main 为打包出来的文件路口
   <br>

2. 修改<code>bill.config.js</code>
   ![image.png](https://i.loli.net/2020/01/14/dUuiNszJeOf4PZr.png)
   修改 input 打包入口文件路径 <code>src/xxxx.jsx</code> 为你的文件名字，假如你的组件叫 Websocket 则改为<code>src/Websocket.jsx</code><br>
   修改 moduleName 模块名字 xxxx 为你的文件模块名字 例如：<code>moduleName: 'Websocket'</code><br>
   <code>extractCSS</code> 为打包出来的 js 文件是否要包含 css 也就是不单独派生出 css 文件<br>
   <code>babel</code> 这边默认已经配置了 jsx 语法 如果有自己的需求可以打开 <code>babelrc: true</code>, 自己添加<code>.babelrc</code>文件编写自己的所需
   <br>

#### 其他同 vue 版一样
