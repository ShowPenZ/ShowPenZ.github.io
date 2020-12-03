---
title: react-slot-machines
date: 2019-10-26 11:39:54
tags: 
 - react 
 - slot machines
top:
categories: 
 - javascript
 - npm package
---
这是一个简单的老虎机组件 
效果截图
![slotMachines.gif](https://i.loli.net/2019/10/28/hbVvUewMcDTXStk.gif)

# react-slot-machines

> A slot machine component for React

## Installation

```
$ npm install react-slot-machines --save
$ yarn add react-slot-machines 
```

## Usage
<!--more-->
``` javascript
class App extends React.Component {
  state = {
    startEngine: false,
    giftAmount: 16,  //礼物种类
    giftPos1: 0,     //老虎机第1槽位停下的礼物索引
    giftPos2: 1,     //老虎机第2槽位停下的礼物索引
    giftPos3: 3,     //老虎机第3槽位停下的礼物索引 
    hasStart: false,
    giftImgUrlArr: []
  };

  componentDidMount() {
    const that = this;
    const { giftAmount } = that.state;

    let array = [];

    for (let i = 1; i <= giftAmount; i++) {
      array.push({ url: require(`../src/images/${i}.png`) });
    }

    that.setState({
      //重复添加奖品数组以拓宽奖池数组长度
      //自定义n圈就得添加n+1个礼物数组
      //多出来得一个是用于真实旋转后落位的

      // giftImgUrlArr: _.concat(array, array, array, array)
      giftImgUrlArr: _.concat(array)
    });
  }

  render() {
    const that = this;
    const {
      startEngine,
      hasStart,
      giftPos1,
      giftPos2,
      giftPos3,
      giftImgUrlArr,
      giftAmount
    } = that.state;
    const onClickEngineStart = () => {
      if (startEngine) {
        return;
      }

      that.setState({
        startEngine: true,
        hasStart: true
      });
    };

    const onEngineCompelet = () => {
      if (giftPos1 === giftPos2 && giftPos1 !== giftPos3) {
        console.log("实在太可惜，再来一次");
        that.setState({
          startEngine: false
        });
      }

      if (giftPos2 === giftPos3 && giftPos2 !== giftPos1) {
        console.log("实在太可惜，再来一次");
        that.setState({
          startEngine: false
        });
      }

      if (
        giftPos1 !== giftPos2 &&
        giftPos1 !== giftPos3 &&
        giftPos2 !== giftPos3
      ) {
        console.log("哇！ 感谢参与");
        that.setState({
          startEngine: false
        });
      }
    };

    return (
      <div className="container">
        <Slot
          giftAmount={giftAmount}
          giftPos1={giftPos1}
          giftPos2={giftPos2}
          giftPos3={giftPos3}
          hasStart={hasStart}
          startEngine={startEngine}
          onClickEngineStart={onClickEngineStart}
          onEngineCompelet={onEngineCompelet}
          // backgroundImg={require("../src/images/sven.jpg")}
          giftImgUrlArr={giftImgUrlArr}
          // customTurns={3}
        />
      </div>
    );
  }
}

export default App;
```
## Properties

``` javascript
  static propTypes = {
    giftPos1: PropTypes.number.isRequired,            //老虎机第1槽位停下的礼物索引
    giftPos2: PropTypes.number.isRequired,            //老虎机第2槽位停下的礼物索引
    giftPos3: PropTypes.number.isRequired,            //老虎机第3槽位停下的礼物索引
    giftType: PropTypes.number.isRequired,            //礼物种类
    startEngine: PropTypes.bool.isRequired,           //老虎机是否启动
    hasStart: PropTypes.bool.isRequired,              //老虎机是否启动过
    onClickEngineStart: PropTypes.func.isRequired,    //点击启动老虎机
    onEngineCompelet: PropTypes.func.isRequired,      //老虎机完全停下的回掉
    giftImgUrlArr: PropTypes.array.isRequired,        //传入的奖品url地址(数组)
    slotDelay2: PropTypes.number,                     //第2槽位的启动延迟(相对于第一槽位)
    slotDelay3: PropTypes.number,                     //第3槽位的启动延迟(相对于第一槽位)
    backgroundImg: PropTypes.string,                  //老虎机的图片(如果没传会有一张默认的圣诞老虎机图片)
    engineDuration: PropTypes.number,                 //老虎机的转动完成时间
    reWindowsContainer: PropTypes.string,             //老虎机的classname传入（包括图片样式）
    reWindows: PropTypes.string,                      //老虎机的槽位classname传入（包括图片样式）
    reGiftContainer: PropTypes.string,                //礼物的classname传入（包括图片样式）
    reStartBtn: PropTypes.string,                     //启动按钮的classname传入
    customTurns: PropTypes.number                     //老虎机旋转圈数
  };

  //提供的一些默认属性
  static defaultProps = {
    slotDelay2: 500,  
    slotDelay3: 1000,
    engineDuration: 8000,
    backgroundImg: require("./images/bg.png"),
    customTurns: 2
  };
```

# License

MIT
