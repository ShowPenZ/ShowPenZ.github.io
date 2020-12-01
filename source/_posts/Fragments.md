---
title: Fragments
date: 2019-06-24 11:14:13
tags: 
 - react
top: 
categories: javascript
---
Fragments 允许将子列表分组，而无需向 DOM 添加额外节点。
<!--more-->

``` javascript
class Table extends React.Component {
  render() {
    return (
      <table>
        <tr>
          <Columns />
        </tr>
      </table>
    );
  }
}

class Columns extends React.Component {
  render() {
    return (
      <div>
        <td>Hello</td>
        <td>World</td>
      </div>
    );
  }
}
```

``` html
<Columns />需要返回多个 <td> 元素以使渲染的 HTML 有效。
如果在 <Columns /> 的 render() 中使用了父 div，
则生成的 HTML 将无效。
```

``` javascript
class Columns extends React.Component {
  render() {
    return (
      <React.Fragment>
        <td>Hello</td>
        <td>World</td>
      </React.Fragment>
    );
  }
}
```

``` html
这样可以正确的输出 <Table />：
```

还可以用更骚的新的短语法来声明Fragments,
你可以像使用任何其他元素一样使用 <> </>，除了它不支持 key 或属性。
``` javascript
class Columns extends React.Component {
  render() {
    return (
      <>
        <td>Hello</td>
        <td>World</td>
      </>
    );
  }
}
```
请注意 目前许多工具尚不支持 ，所以直到工具支持之前，你可能要显式的使用 <React.Fragment>。

