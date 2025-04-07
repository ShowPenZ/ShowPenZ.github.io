---
title: js 浮点数运算--使用decimal.js
date: 2020-03-24 11:21:19
tags: js精度处理
top:
categories: js
---

为了避免 js 运算出现如![image.png](https://i.loli.net/2020/04/26/lRPemr91E6FIvqW.png) 这种情况
推荐使用 decimal.js 这个库来帮助我们处理精度问题

1.首先引入
(1). 标签引入方式 <code>\<script src="https://cdn.bootcss.com/decimal.js/10.2.0/decimal.js"></script></code>
(2). <code>npm intall decimal.js or yarn add decimal.js</code>

2.使用方式
<!--more-->

```javascript
//例如 加法
let a = 0.1,
  b = 0.2;
let c;

c = new Decimal(a).add(new Decimal(b)).toNumber(); // 0.3
```

![image.png](https://i.loli.net/2020/03/24/7nASorUbHaiI1NO.png)

3.简易封装

```javascript
import _ from "lodash"; // const _ = require("lodash");
import Decimal from "decimal.js"; // const _ = require("lodash");

const BLANK_CHAR = "-";
const isBlankChar = value => value === BLANK_CHAR;
const isNumericString = value =>
  /^[-+]?([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][-+]?[0-9]+)?$/.test(value);
const isNumericValue = value =>
  (hasString(value) && isNumericString(value)) || hasNumber(value);

// 字符串判断
function hasString(value) {
  return _.isString(value) && !_.isEmpty(value);
}

// 数字判断
function hasNumber(value) {
  return _.isNumber(value) && _.isFinite(value);
}

function getNumberValue(value) {
  if (isBlankChar(value)) {
    return BLANK_CHAR;
  }

  return isNumericValue(value) ? value : 0;
}

// 科里化处理参数传递
function generateOperationFnUseDecimalJs(op) {
  return (x, y) => {
    if (isBlankChar(x) || isBlankChar(y)) {
      return BLANK_CHAR;
    }

    if (op === "div" && getNumberValue(y) === 0) {
      return 0;
    }

    return isNumericValue(x) && isNumericValue(y)
      ? new Decimal(x)[op](new Decimal(y)).toFixed()
      : 0;
  };
}

export const DecimalPlus = generateOperationFnUseDecimalJs("plus");
export const DecimalMinus = generateOperationFnUseDecimalJs("minus");
export const DecimalMultiply = generateOperationFnUseDecimalJs("times");
export const DecimalDivide = generateOperationFnUseDecimalJs("div");

// 使用方法
DecimalPlus(0.1, 0.2); //加法 0.3
DecimalMinus(0.2, 0.1); //减法 0.1
DecimalMultiply(0.1, 0.3); //乘法 0.03
DecimalDivide(0.3, 0.1); //除法 3
```
