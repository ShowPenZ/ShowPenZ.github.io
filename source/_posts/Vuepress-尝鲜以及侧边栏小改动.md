---
title: Vuepress 尝鲜以及侧边栏小改动
date: 2020-04-18 23:56:31
tags:
  - Vue
  - Vuepress
top:
categories: 静态博客
---

今天试了下 VuePress 这个静态网页生成工具
制作了一个面试题集(会陆续增加功能，以及习题的增加)
![image.png](https://i.loli.net/2020/04/18/ZsvwVYWeJXAa8Mk.png)
<!--more-->
### package.json 文件

```json
{
  "name": "interviewExercise",
  "version": "1.0.0",
  "description": "doc for interviewExercise",
  "main": "index.js",
  "directories": {
    "doc": "docs"
  },
  "scripts": {
    "dev": "vuepress dev docs",
    "deploy": "bash deploy.sh",
    "push": "bash push.sh",
    "docs:build": "vuepress build docs"
  },
  "repository": {
    "type": "git",
    "url": "git@github.com:ShowPenZ/interviewExercise.git"
  },
  "author": "",
  "license": "ISC",
  "bugs": {
    "url": "https://github.com/ShowPenZ/interviewExercise/issues"
  },
  "devDependencies": {
    "vuepress": "^1.0.0-alpha.44"
  },
  "dependencies": {
    "gh-pages": "^2.0.1"
  }
}
```

1. 第一步 构造文件目录

```bash
# 在项目根目录创建一个 docs 目录
mkdir docs


# 在项目根目录创建一个 javascript 目录
cd docs

mkdir javascript

# 创建一个 markdown 文件
echo '# Hello VuePress' > docs/README.md

# 开始编写文档
npm run dev
```

再在 docs 目录下创建一个.vuepress 文件夹
以及在.vuepress 文件夹下添加 config.js 配置

文件目录结构如下
![image.png](https://i.loli.net/2020/04/19/NaFK53mMQjgHqRw.png)

config.js 简单配置如下

```javascript
module.exports = {
  // 第一种
  // 因为我是发布到 https://showpenz.github.io/InterviewExercise
  // 所以将 .vuepress/config.js 中的 base 设置为你的仓库名称。
  // 例如，如果你的仓库是 https://github.com/showpenz/InterviewExercise ，
  // 则已部署的页面将在 https://showpenz.github.io/InterviewExercise 上可用。
  // 在这种情况下，你应该将base设置为 "/InterviewExercise/" 。

  // 第二种
  // 如果发布到 https://showpenz.github.io
  // 例如，如果你的仓库是 https://github.com/showpenz/ ，
  // 则已部署的页面将在 https://showpenz.github.io/ 上可用。
  // 在这种情况下，你应该将base设置为 "/" 。

  base: "/interviewExercise",
  dest: "dist",

  description: "面试题",
  locales: {
    // 键名是该语言所属的子路径
    // 作为特例，默认语言可以使用 '/' 作为其路径。
    "/": {
      lang: "en-US", // 将会被设置为 <html> 的 lang 属性
      title: "InterviewExercise",
      description: "Vue-powered Static Site Generator",
    },
    "/zh/": {
      lang: "zh-CN",
      title: "练习题",
      description: "Vue 驱动的静态网站生成器",
    },
  },
  themeConfig: {
    editLinks: false,
    docsDir: "docs",
    nav: [],
    locales: {
      "/": {
        selectText: "选择语言",
        label: "English",
        ariaLabel: "Languages",
        editLinkText: "Edit this page on GitHub",
        // nav: [{ text: "Nested", link: "/nested/", ariaLabel: "Nested" }],
        sidebar: {
          "/": [
            {
              title: "Javascript", //侧边栏主标题
              children: [
                {
                  title: "DataStructureTransformation", // 侧边栏二级标题
                  children: [
                    ["javascript/DataStructureTransformation/1", "question 1"], // 数组第0项是需要显示的md文件的文件夹的文件路径  第1项是侧边栏的三级标题
                  ],
                },
              ],
            },
          ],
        },
      },
      "/zh/": {
        // 多语言下拉菜单的标题
        selectText: "Languages",
        // 该语言在下拉菜单中的标签
        label: "简体中文",
        // 编辑链接文字
        editLinkText: "在 GitHub 上编辑此页",
        // Service Worker 的配置

        // 当前 locale 的 algolia docsearch 选项
        // nav: [{ text: "嵌套", link: "/zh/nested/" }],
        sidebar: {
          "/zh/": [
            {
              title: "Javascript",
              children: [
                {
                  title: "数据结构转换",
                  children: [
                    ["/zh/javascript/DataStructureTransformation/1", "第1题"],
                  ],
                },
              ],
            },
          ],
        },
      },
    },
  },
};
```

2. 书写完毕配配置部署到 github 的 git-page

<font color='red'>默认提前在 github 开好新的项目，打开 gitpage 并与当前项目建立好关系</font>

首先在根目录编写 deploy.bash(windows 系统需进行一些处理)

```bash
#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
npm run docs:build

# 进入生成的文件夹
cd docs/.vuepress/dist

# 如果是发布到自定义域名

git init
git add -A
git commit -m 'deploy'

# 如果发布到 https://<USERNAME>.github.io
# git push -f git@github.com:showpenz/showpenz.github.io.git master

# 如果发布到 https://<USERNAME>.github.io/<REPO>
# 把下面的地址换成你的
# git push -f git@github.com:showpenz/interviewExercise.git master:gh-pages

cd -
```

然后在根目录执行 npm run deploy.bash 便会自动 build 好并打包在.vuepress 下生成 dist 文件夹，然后自动 push 到 git-pages 分支

3. 因为我不是全局安装 vuepress 工具 所以好多文件没有自动配置以及生成这里介绍一个我遇到的问题

根据上面那种简单配置的 config.js 往下走 会导致你新增一个 md 文件就要手动去 config.js 里面增加 sidebar 因为我做的是三级的侧边栏所以好像自动生成侧边栏的功能没法用，我想以后不论增加文件夹还是文件都能自动关联到侧边栏，所以，没关系咱们手写一个。。。

首先啥也别说 先建一个工具类的文件夹 utils,新增 fileHelper.js

```javascript
const fs = require("fs");

const fileHelper = {
  getFileName: function (rootPath, filePath) {
    const fileTypes = /\.md$/; //只匹配以md结尾的文件
    let fileNames = [];

    fs.readdirSync(rootPath + filePath).forEach((file) => {
      let tempFilePath = "";
      let generateArr = new Array();

      fullPath = rootPath + filePath + "/" + file;
      //异步获取文件状态
      let fileInfo = fs.statSync(fullPath);

      if (fileInfo.isFile() && fileTypes.test(file) > 0) {
        //剔除README.md
        if (file !== "README.md") {
          file = file.replace(".md", "");
          tempFilePath = filePath + "/" + file;
        }

        generateArr.push(tempFilePath, file);
        fileNames.push(generateArr); // 构造二维数组
      }
    });

    fileNames.sort(); // 排序

    return fileNames;
  },
};

module.exports = fileHelper;
```

再在 utils 下新增一个 help.js

```javascript
const fileHelper = require("./fileHelper");

const isString = Object.prototype.toString;
const isArray = (arr) => {
  return isString.call(arr) === "[object Array]";
};

const isObject = (arr) => {
  return isString.call(arr) === "[object Object]";
};

const helper = {
  genSidebar: function (
    title,
    children = [],
    collapsable = true,
    sidebarDepth = 1
  ) {
    let arr = new Array();
    let genData = null;

    if (children && isArray(children[0]) && isObject(children[0][0])) {
      let tempArr = [];

      children.map((d) => {
        tempArr.push(d[0]);
      });

      genData = tempArr;
    } else {
      genData = children;
    }

    arr.push({
      title,
      children: genData,
      collapsable,
      sidebarDepth,
    });

    return arr;
  },
  generateArr: function (arr, rootpath) {
    const that = this;
    let tempArr = [];

    arr.map((d, i) => {
      tempArr.push(
        that.genSidebar(
          d.title,
          fileHelper.getFileName(rootpath, d.path),
          d.collapsable,
          d.sidebarDepth || 1
        )
      );
    });

    return tempArr;
  },
};

module.exports = helper;
```

再在 docs 文件夹下新增一个 fileData 文件夹以及在 fileData 内创建 sidebarData.js

```javascript
// 构建这样的数据类型
const sidebarData = {
  enFileData: [
    {
      title: "DataStructureTransformation",
      path: "/en/javascript/DataStructureTransformation",
      collapsable: true,
    },
    {
      title: "eventHandler",
      path: "/en/javascript/eventHandler",
      collapsable: true,
    },
    {
      title: "basic",
      path: "/en/javascript/basic",
      collapsable: true,
    },
    {
      title: "dataProcessing",
      path: "/en/javascript/dataProcessing",
      collapsable: true,
    },
  ],

  zhFileData: [
    {
      title: "数据结构转换",
      path: "/javascript/DataStructureTransformation",
      collapsable: true,
    },
    {
      title: "事件处理相关",
      path: "/javascript/eventHandler",
      collapsable: true,
    },
    {
      title: "基础类",
      path: "/javascript/basic",
      collapsable: true,
    },
    {
      title: "数据处理",
      path: "/javascript/dataProcessing",
      collapsable: true,
    },
  ],
};

module.exports = sidebarData;
```

最后修改 config.js

```javascript
const path = require("path");
const rootpath = path.dirname(__dirname); //执行一次dirname将目录定位到docs目录
// const util = require("util");
const sideBarData = require("./fileData/sideBarData");
const helper = require("./utils/helper");

const en = helper.genSidebar(
  "Javascript",
  helper.generateArr(sideBarData.enFileData, rootpath),
  true
);

const zh = helper.genSidebar(
  "Javascript",
  helper.generateArr(sideBarData.zhFileData, rootpath),
  true
);

// console.log(util.inspect(en, { showHidden: false, depth: null, colors: true })); // alternative shortcutconsole.log(util.inspect(myObject, false, null, true /* enable colors */))

module.exports = {
  base: "/interviewExercise/",
  dest: "docs/.vuepress/dist",

  description: "面试题",
  locales: {
    // 键名是该语言所属的子路径
    // 作为特例，默认语言可以使用 '/' 作为其路径。
    // "/": {
    //   lang: "en-US", // 将会被设置为 <html> 的 lang 属性
    //   title: "InterviewExercise",
    //   description: "Vue-powered Static Site Generator",
    // },

    "/en/": {
      lang: "en-US", // 将会被设置为 <html> 的 lang 属性
      title: "InterviewExercise",
      description: "Vue-powered Static Site Generator",
    },
    "/": {
      lang: "zh-CN",
      title: "练习题",
      description: "Vue 驱动的静态网站生成器",
    },
  },
  themeConfig: {
    editLinks: false,
    docsDir: "docs",
    nav: [],
    locales: {
      "/en/": {
        selectText: "选择语言",
        label: "English",
        ariaLabel: "Languages",
        editLinkText: "Edit this page on GitHub",
        // nav: [{ text: "Nested", link: "/nested/", ariaLabel: "Nested" }],
        sidebar: {
          "/en/": en,
        },
      },
      "/": {
        // 多语言下拉菜单的标题
        selectText: "Languages",
        // 该语言在下拉菜单中的标签
        label: "简体中文",
        // 编辑链接文字
        editLinkText: "在 GitHub 上编辑此页",
        // Service Worker 的配置

        // 当前 locale 的 algolia docsearch 选项
        // nav: [{ text: "嵌套", link: "/zh/nested/" }],
        sidebar: {
          "/": zh,
        },
      },
    },
  },
};
```

这样通过

```javascript
const en = helper.genSidebar(
  "Javascript",
  helper.generateArr(sideBarData.enFileData, rootpath),
  true
);

const zh = helper.genSidebar(
  "Javascript",
  helper.generateArr(sideBarData.zhFileData, rootpath),
  true
);
```

就能不用再手动目录了，新增一个文件夹就可以去 sidebarData.js 内新增侧边栏标题和文件路径就行了

以上就是暂时对 vuepress 的浅浅尝试
