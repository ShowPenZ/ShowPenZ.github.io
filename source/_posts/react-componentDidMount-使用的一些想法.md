---
title: react componentDidMount 使用的一些想法
date: 2020-03-25 17:42:48
tags:
  - react
  - 代码优化
top:
categories: javascript
---

React componentDidMount 中尽量别使用 setState 方法

在 componentDidMount()中，你可以立即调用 setState()。它将会触发一次额外的渲染，但是它将在浏览器刷新屏幕之前发生。这保证了在此情况下即使 render()将会调用两次，用户也不会看到中间状态。谨慎使用这一模式，因为它常导致性能问题。在大多数情况下，你可以 在 constructor()中使用赋值初始状态来代替。然而，有些情况下必须这样，比如像模态框和工具提示框。这时，你需要先测量这些 DOM 节点，才能渲染依赖尺寸或者位置的某些东西。

componentDidMount 本身处于一次更新中，我们又调用了一次 setState，就会在未来再进行一次 render，造成不必要的性能浪费，大多数情况可以设置初始值来搞定。当然在componentDidMount我们可以调用接口，再回调中去修改state。
