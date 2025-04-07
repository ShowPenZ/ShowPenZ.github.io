---
title: react组件转换成vue组件(2)
date: 2020-01-09 13:58:01
tags:
  - react
  - vue
top:
categories:
  - javascript
  - npm package
---

承接上文这次使用我的另一个组件[vue-simpleWS](https://github.com/ShowPenZ/vue-simpleWS)来对比下两个框架的使用上的不同

上源码 Vue
<!--more-->

```vue
<template>
  <div>
    <slot></slot>
  </div>
</template>

<script>
export default {
  name: "Vue-simple-Ws",
  props: {
    url: {
      type: String,
      required: true
    },
    debug: {
      type: Boolean,
      default: false
    },
    reconnect: {
      type: Boolean,
      default: true
    }
  },
  data() {
    const that = this;
    return {
      instance: null,
      reconnectFailureTimes: 0,
      reconnectTimer: null,
      needReconnet: true,
      WS: window.WebSocket
        ? new window.WebSocket(that.url)
        : new window.MozWebSocket(that.url)
    };
  },
  watch: {},
  mounted() {
    const that = this;
    that.structureWebSocket();
  },
  beforeDestroy() {
    const that = this;
    that.destroy();
  },
  destroy() {
    const that = this;
    that.needReconnet = false;
    clearTimeout(that.reconnectTimer);
    that.printLog(`WS is close`);
    that.WS.close();
  },
  methods: {
    structureWebSocket() {
      const that = this;
      that.WS.onopen = () => {
        that.printLog("ws is connected");
        that.$emit("onOpen", that.sendData);
      };
      that.WS.onmessage = data => {
        that.printLog(`wsData:${data.data}`);
        that.$emit("onMessage", data.data);
      };
      that.WS.onclose = e => {
        const { code, reason, wasClean } = e;
        that.printLog(`WS is disconneted,reason:${reason}`);
        that.$emit("onClose", code, reason, wasClean);
        if (that.reconnect && that.needReconnet) {
          that.reconnectFailureTimes++;
          if (that.reconnectFailureTimes < 3) {
            that.reconnectTimer = window.setTimeout(() => {
              that.setState({
                WS: window.WebSocket
                  ? new window.WebSocket(that.url)
                  : new window.MozWebSocket(that.url)
              });
              that.structureWebSocket();
            }, 15 * 1000);
          }
        }
      };
      that.WS.onerror = e => {
        that.$emit("onError", e);
      };
    },
    sender(msg) {
      const that = this;
      if (that.WS && that.WS.readyState === 1) {
        that.WS.send(msg);
      }
    },
    sendData(msg) {
      const that = this;
      return that.sender(msg);
    },
    printLog(val) {
      const that = this;
      if (that.debug) {
        console.log(val);
      }
    }
  }
};
</script>
<style scoped></style>
```

react

```react
import React from 'react';
import PropTypes from 'prop-types';

function isFunction(arg) {
  if (typeof arg === 'function') {
    return true;
  }
}

class Websocket extends React.Component {
  static propTypes = {
    url: PropTypes.string.isRequired,
    onOpen: PropTypes.func,
    onMessage: PropTypes.func.isRequired,
    onError: PropTypes.func,
    onClose: PropTypes.func,
    debug: PropTypes.bool,
    reconnect: PropTypes.bool,
  };

  static defaultProps = {
    debug: false,
    reconnect: true,
  };

  constructor(props) {
    super(props);
    const that = this;
    const { url } = that.props;

    that.state = {
      WS: window.WebSocket ? new window.WebSocket(url) : new window.MozWebSocket(url),
      reconnectTime: 0,
    };

    that.reconnectFailureTimes = 0;
    that.reconnectTimer = null;
    that.needReconnet = true;
  }

  componentDidMount() {
    const that = this;

    that.structureWebSocket();
  }

  componentWillUnmount() {
    const that = this;
    const { WS } = that.state;

    that.needReconnet = false;

    clearTimeout(that.reconnectTimer);

    that.printLog(`WS is close`);

    WS.close();
  }

  structureWebSocket = () => {
    const that = this;
    const { WS } = that.state;
    const { onOpen, onMessage, onError, onClose, reconnect, url } = that.props;

    WS.onopen = () => {
      that.printLog('ws is connected');

      if (isFunction(onOpen)) {
        onOpen(that.sendData);
      }
    };

    WS.onmessage = data => {
      that.printLog(`wsData:${data.data}`);

      if (isFunction(onMessage)) {
        onMessage(data.data);
      }
    };

    WS.onclose = e => {
      const { code, reason, wasClean } = e;

      that.printLog(`WS is disconneted,reason:${reason}`);

      if (isFunction(onClose)) {
        onClose(code, reason, wasClean);
      }

      if (reconnect && that.needReconnet) {
        that.reconnectFailureTimes++;

        if (that.reconnectFailureTimes < 3) {
          that.reconnectTimer = window.setTimeout(() => {
            that.setState({
              WS: window.WebSocket ? new window.WebSocket(url) : new window.MozWebSocket(url),
            });
            that.structureWebSocket();
          }, 15 * 1000);
        }
      }
    };

    WS.onerror = e => {
      if (isFunction(onError)) {
        onError();
      }
    };
  };

  sender = msg => {
    const that = this;
    const { WS } = that.state;

    if (WS && WS.readyState === 1) {
      WS.send(msg);
    }
  };

  sendData = msg => {
    const that = this;

    return that.sender(msg);
  };

  printLog = val => {
    const that = this;
    const { debug } = that.props;

    if (debug) {
      console.log(val);
    }
  };

  render() {
    const that = this;
    const { children } = that.props;

    return <div>{children}</div>;
  }
}

export default Websocket;
```

代码比较

1. 生命周期
   react ![image.png](https://i.loli.net/2020/01/09/ZoYxEcAzmGSVe5q.png)
   vue ![image.png](https://i.loli.net/2020/01/09/BTyPGesz9VYQCwr.png)
2. 变量声明
   react ![image.png](https://i.loli.net/2020/01/09/iHFvJaZrA3XyzET.png)
   vue ![image.png](https://i.loli.net/2020/01/09/gh9wtCkJuGRyxm1.png)
3. 函数
   react 组件内的函数直接放在 class 类内部走箭头函数即可
   vue   组件的内定义的函数要放在 methods 对象内

个人还是喜欢react api较少 比较天马行空 vue支持jsx之后无需使用模版语法也挺不错的
反正react 真香 一giao我里giao

源代码以及项目地址 
react  [react-websocket](https://github.com/ShowPenZ/react-websocket)
vue  [vue-simpleWS](https://github.com/ShowPenZ/vue-simpleWS)