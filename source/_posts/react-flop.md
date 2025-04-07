---
title: react-flop
date: 2019-10-15 14:53:06
tags: 
 - react 
 - websocket
top:
categories: 
 - javascript
 - npm package
---
react-flop组件 
提供一个小功能翻转卡片功能可作为开奖翻转使用

# react-flop

> A simple flop component for React

## Installation

```
$ npm install react-flop --save
$ yarn add react-flop
```

## Usage

``` javascript
class App extends React.Component {
  constructor(props) {
    super(props);
    const that = this;

    that.state = {
      haveGift: false,
      isFlop: false
    };
  }

  render() {
    const that = this;
    const { haveGift, isFlop } = that.state;
    const slot = () => {
      if (!isFlop) {
        return null;
      }

      if (haveGift) {
        return <div>获奖了</div>;
      } else {
        return <div>GG</div>;
      }
    };

    const onClick = () => {
      that.setState({
        isFlop: true,
        haveGift: true
      });
    };

    return (
      <Flop
        imgFLop={require("./images/WechatIMG3.png")}
        imgFLoped={require("./images/WechatIMG2.png")}
        slot={slot()}
        onClick={onClick}
        haveGift={haveGift}
        isFlop={isFlop}
        imgFLopWidth={686}
        imgFLopHeight={272}
      />
    );
  }
}

export default App;
```

## Properties

``` javascript
  static propTypes = {
    imgFLop: PropTypes.string.isRequired,      //Preflip picture
    imgFLoped: PropTypes.string.isRequired,    //Flipped picture
    cardName: PropTypes.string,                //Custom Components classname
    slot: PropTypes.node,                      //Reserved Node Slot
    onClick: PropTypes.func.isRequired,        //onclick
    haveGift: PropTypes.bool,                  //awarded or not
    isFlop: PropTypes.bool,                    //Flop or not
    imgFLopWidth: PropTypes.number.isRequired, //Picture width
    imgFLopHeight: PropTypes.number.isRequired,//Picture height


  };

  static defaultProps = {
    cardName: '',
    slot: null,
    isFlop: false,
    haveGift: false,
  };
```

# License

MIT
