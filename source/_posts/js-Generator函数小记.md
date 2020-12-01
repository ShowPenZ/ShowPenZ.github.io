---
title: js Generator函数小记
date: 2019-12-24 10:41:24
tags: Generator
top:
categories: js
---

generator 函数运行结果释义

遇到<font color=red>yield 表达式，就暂停执行后面的操作</font>，
并将紧跟在<font color=red>yield 后面的那个表达式的值，作为返回的对象的 value 属性值</font>。
下一次调用 next 方法时，再继续往下执行，直到遇到下一个 yield 表达式。
<font color=red>next 方法可以带一个参数，该参数就会被当作上一个 yield 表达式的返回值</font>。

```javascript
function* generator(x) {
  let y = 1 * (yield x + 2);
  let z = yield y / 2;

  return x + y + z;
}
```

```javascript
const fun1 = generator(2);
```
<!--more-->
```javascript
fun1.next();
```

{value:4, done:false}
第一步 第一次使用 next 方法时，运行 fun1.next()走到第一个 yield 里所以 value 为 4

```javascript
fun1.next();
```

{value:NaN, done:false}
第二步 运行 fun1.next() 没传参数 导致 yield (x + 2) 返回 undefined
则 y = 1 \* undefined 即 yield(y/2)为 NaN

```javascript
fun1.next();
```

{value:NaN, done:true}
第三步 运行 fun1.next() 没传参数 导致 yield (y / 2) 返回 undefined
则 z = undefined 即 4 + NaN + undefinde 为 NaN

```javascript
const fun2 = generator(2);

fun2.next();
```

{ value:4, done:false }
第一步 第一次使用 next 方法时，运行 fun1.next()走到第一个 yield 里所以 value 为 4

```javascript
fun2.next(5);
```

{ value:2.5, done:false }
第二步 运行 fun1.next() 传递参数 5 并将上一次 yield 表达式的值设为传递的参数 5 则 yield (x + 2) 返回 5
则 y=1 \* 5 为 5 即 yiled(5 / 2) 为 2.5

```javascript
fun2.next(6);
```

{ value:13, done:true }
第三步 运行 fun1.next() 传递参数 6 并将上一次 yield 表达式的值设为传递的参数 6 则 yield (y / 2) 返回 6
则 z = 6 往下走再无 yiled，直接执行 return = x + y + z = 2 + 5 + 6 = 13
