---
title: react组合
date: 2019-06-21 17:27:48
tags: 
 - react 
categories: 
 - javascript
---

react 学习笔记--组合
有些组件无法提前知晓它们子组件的具体内容。
可以使用一个特殊的 <code><font color=#FF0000>children</font></code> prop 来将他们的子组件传递到渲染结果中：
<!--more-->
``` javascript
function ParentComponent(props) {
  return (
    <div className={'ParentComponent ParentComponent-' + props.color}>
      {props.children}
    </div>
  );
}

function renderComponent() {
  return (
    <ParentComponent color="blue">
      <h1 className="title">
        111
      </h1>
      <p className="message">
        222
      </p>
    </ParentComponent>
  );
}
```
还可以预留几个下几个位置，这种情况下我们可以不实用children
``` javascript
function ParentComponent(props) {
  return (
    <div className="ParentComponent">
      <div className="ParentComponent-left">
        {props.left}
      </div>
      <div className="ParentComponent-right">
        {props.right}
      </div>
    </div>
  );
}

function App() {
  return (
    <ParentComponent
      left={
        <Component1 />
      }
      right={
        <Component2 />
      } />
  );
}
```