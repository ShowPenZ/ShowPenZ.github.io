---
title: Antd 修改全局暂无数据的默认图片
date: 2019-09-09 11:46:22
tags:
  - Antd
  - react
top:
categories: javascript
---

项目中使用Antd时,遇到需要修改数据为空时的默认图片。
在相应的layout里的<code>ConfigProvider</code>中的config内做如下配置即可。
<!--more-->

```javascript
import { ConfigProvider, Empty } from 'antd';
import React from 'react';

//你的layout
const layout = () =>{
    ...
}

 render() {
    const renderEmpty = () => {
        return <Empty image={Empty.PRESENTED_IMAGE_DEFAULT} />;
    };

    const config = {
      autoInsertSpaceInButton: false,
      // csp: { nonce: '' },
      renderEmpty: renderEmpty,
      // getPopupContainer: () => document.body,
      // locale: ,
    };

    return <ConfigProvider {...config}>{layout}</ConfigProvider>;
}
```
