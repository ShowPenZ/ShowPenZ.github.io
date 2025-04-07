---
title: react-simple-websocket
date: 2019-10-11 16:12:55
tags: 
 - react 
 - websocket
top:
categories: 
 - javascript
 - npm package
---

react websocket组件容器
提供 onOpen，onMessage,onError,onClose等方法,
是一个轻便的websocket组件
支持重连功能

# react-simple-websocket

> A simple websocket component for React

## Installation

```
$ npm install react-simple-websocket --save
$ yarn add react-simple-websocket
```

## Usage

``` javascript
import React from 'react';
import SimpleWS from 'react-simple-websocket';

export default class Example extends React.Component {
  constructor(props) {
    super(props);
    const that = this;

    that.state = {
      wsData: "",
    };

    that.sender = null;
  }

  onMessage = data => {
    const that = this;

    //get the data from ws
    that.setState({
      wsData: data
    });
  };

  onOpen = sender => {
    const that = this;
    that.sender = sender;

    //use sender to send your data
    sender("xxxxx");
  };

   onClick = () => {
    const that = this;

    that.sender('halo,it's me!');
  };

  render() {
    return (
      <div>
        <SimpleWS
          url="ws://localhost:8080"
          onOpen={that.onOpen}
          onMessage={that.onMessage}
          onClose={that.onClose}
        />
        <button onClick={that.onClick}>send</button>
      </div>
    );
  }
};
```

## Properties

``` javascript
  static propTypes = {
    url: PropTypes.string.isRequired,
    onOpen: PropTypes.func,
    onMessage: PropTypes.func.isRequired,
    onError: PropTypes.func,
    onClose: PropTypes.func,
    debug: PropTypes.bool,
    reconnect: PropTypes.bool
  };

  static defaultProps = {
    debug: false,
    reconnect: true
  };
```

# License

MIT

